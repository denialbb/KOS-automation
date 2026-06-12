# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "mcp[cli]>=1.2.0",
#     "httpx",
#     "python-dotenv",
# ]
# ///
import os
import sys
import httpx
from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Initialize FastMCP server
# We name it "openrouter-gateway" to align with our config
mcp = FastMCP("openrouter-gateway")

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

def call_openrouter(model_id: str, prompt: str) -> str:
    """Helper function to call the OpenRouter API with a given model and prompt."""
    if not OPENROUTER_API_KEY:
        return (
            "Error: OPENROUTER_API_KEY environment variable is not set.\n"
            "Please check that you have created a `.env` file in the workspace root "
            "containing `OPENROUTER_API_KEY=your_key_here`."
        )
    
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://github.com/denialbb/KOS-automation",
        "X-Title": "Antigravity Orchestrator",
    }
    
    payload = {
        "model": model_id,
        "messages": [
            {"role": "user", "content": prompt}
        ]
    }
    
    try:
        # We use a generous timeout as reasoning models like DeepSeek R1 can take a while to think
        with httpx.Client(timeout=120.0) as client:
            response = client.post(OPENROUTER_URL, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()
            if "choices" in data and len(data["choices"]) > 0:
                return data["choices"][0]["message"]["content"]
            else:
                return f"Error: Received unexpected JSON structure from OpenRouter: {data}"
    except httpx.HTTPStatusError as e:
        return f"HTTP Error from OpenRouter: {e.response.status_code} - {e.response.text}"
    except Exception as e:
        return f"Exception communicating with OpenRouter: {str(e)}"

@mcp.tool()
def qwen_reason(prompt: str) -> str:
    """Useful for coding, program implementation, syntax correction, and software design tasks.
    Routes to Qwen 3 Coder (Free) via OpenRouter.
    """
    # Print to stderr for server side tracking (stdout is used for JSON-RPC)
    print("Calling Qwen 3 Coder (Free) via OpenRouter...", file=sys.stderr)
    return call_openrouter("qwen/qwen3-coder:free", prompt)

@mcp.tool()
def deepseek_reason(prompt: str) -> str:
    """Useful for mathematical reasoning, complex logic, scientific calculations, and deep troubleshooting.
    Routes to Gemma 4 31B IT (Free reasoning) via OpenRouter.
    """
    print("Calling Gemma 4 (Free) via OpenRouter...", file=sys.stderr)
    return call_openrouter("google/gemma-4-31b-it:free", prompt)

@mcp.tool()
def llama_reason(prompt: str) -> str:
    """Useful for general text drafting, explanation of concepts, summarization, and formatting.
    Routes to Llama 3.3 70B Instruct (Free) via OpenRouter.
    """
    print("Calling Llama 3.3 70B Instruct (Free) via OpenRouter...", file=sys.stderr)
    return call_openrouter("meta-llama/llama-3.3-70b-instruct:free", prompt)

if __name__ == "__main__":
    mcp.run()
