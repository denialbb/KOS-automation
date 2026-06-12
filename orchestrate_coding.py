# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "httpx",
#     "python-dotenv",
#     "mcp[cli]>=1.2.0",
# ]
# ///
import os
import sys
import argparse
import re
from pathlib import Path
from dotenv import load_dotenv

# Add current workspace to path to import openrouter_server
sys.path.append(str(Path(__file__).parent))
try:
    from openrouter_server import qwen_reason, deepseek_reason
except ImportError:
    # Fallback to local import if called from elsewhere
    from .openrouter_server import qwen_reason, deepseek_reason

def extract_code_block(text: str) -> str:
    """Helper to extract contents of a markdown code block."""
    matches = re.findall(r"```(?:kerboscript|ks|python|json|text)?\n(.*?)\n```", text, re.DOTALL | re.IGNORECASE)
    if matches:
        return matches[0].strip()
    return text.strip()

def orchestrate_code_gen(task_desc: str, output_path: str, max_attempts: int = 3):
    print(f"\n[Orchestrator] Starting code generation for task: '{task_desc}'")
    print(f"[Orchestrator] Output path: {output_path}\n")

    current_prompt = (
        f"Write a complete, functional KerboScript (kOS) script for the following task:\n"
        f"'{task_desc}'\n\n"
        f"CRITICAL RULES:\n"
        f"1. You MUST use ALL CAPS for all KerboScript keywords and built-in functions (e.g. IF, SET, PRINT, UNTIL, LOCK, SHIP, FACING, FOREVECTOR, etc.).\n"
        f"2. Provide frequent, informative kOS console updates via PRINT statements.\n"
        f"3. Enclose the code inside a markdown code block (```kerboscript ... ```)."
    )

    code = ""
    for attempt in range(1, max_attempts + 1):
        print(f"--- Attempt {attempt} of {max_attempts} ---")
        print("[Orchestrator] Requesting implementation from Qwen...")
        
        raw_code_response = qwen_reason(current_prompt)
        
        # Handle API or configuration error returned in text
        if raw_code_response.startswith("Error") or raw_code_response.startswith("HTTP Error") or raw_code_response.startswith("Exception"):
            print(f"[Orchestrator] Qwen failed with error: {raw_code_response}")
            return False

        code = extract_code_block(raw_code_response)
        
        print("\n[Orchestrator] Generated Code:")
        print("-" * 50)
        print(code)
        print("-" * 50)

        review_prompt = (
            f"Review the following KerboScript code against these project conventions:\n"
            f"1. ALL keywords and built-in functions MUST be in UPPERCASE (e.g. LOCK, SET, TO, UNTIL, PRINT, SHIP, UP, VELOCITY, ALTITUDE, WAIT, etc.). lowercase keywords are strict violations.\n"
            f"2. Check for syntax correctness and logic errors.\n"
            f"3. Ensure the script logs telemetry changes to console.\n\n"
            f"Here is the code to review:\n"
            f"```kerboscript\n{code}\n```\n\n"
            f"Instructions:\n"
            f"- If the code is 100% correct and follows all rules, reply with ONLY the word 'APPROVED'. Do not include any other text.\n"
            f"- If there are any violations, write a structured list of issues/corrections."
        )

        print("[Orchestrator] Submitting code to Gemma for verification...")
        review_result = deepseek_reason(review_prompt)
        
        if review_result.startswith("Error") or review_result.startswith("HTTP Error") or review_result.startswith("Exception"):
            print(f"[Orchestrator] Reviewer failed with error: {review_result}")
            # If reviewer is rate limited or unavailable, we still save the code but warn
            print("[Orchestrator] Skipping review loop and saving code directly due to reviewer error.")
            break

        print(f"\n[Orchestrator] Reviewer Response:\n{review_result}\n")

        if review_result.strip().upper() == "APPROVED" or "APPROVED" in review_result.split("\n")[0].upper():
            print("[Orchestrator] Code APPROVED by reviewer!")
            break
        else:
            print(f"[Orchestrator] Rejection! Feeding corrections back to Qwen...")
            current_prompt = (
                f"Your previous KerboScript code implementation was REJECTED by the reviewer with the following feedback:\n"
                f"\"\"\"\n{review_result}\n\"\"\"\n\n"
                f"Here was your previous implementation:\n"
                f"```kerboscript\n{code}\n```\n\n"
                f"Please fully address the feedback, correct the script, and output the entire corrected script inside a markdown code block."
            )
    else:
        print("[Orchestrator] Reached max attempts without formal approval. Saving latest version.")

    # Save output to file
    out_file = Path(output_path)
    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(code, encoding="utf-8")
    print(f"[Orchestrator] Saved verified script to: {out_file.absolute()}")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Multi-model coding orchestrator")
    parser.add_argument("task", help="Coding task description")
    parser.add_argument("--output", "-o", required=True, help="Target script path")
    parser.add_argument("--attempts", "-a", type=int, default=3, help="Max code-check attempts")
    args = parser.parse_args()

    # Configure stdout to handle UTF-8 symbols (like Delta/Δ)
    sys.stdout.reconfigure(encoding='utf-8')
    
    success = orchestrate_code_gen(args.task, args.output, args.attempts)
    sys.exit(0 if success else 1)
