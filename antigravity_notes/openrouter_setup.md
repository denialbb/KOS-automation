# OpenRouter Multi-Model Orchestration Setup

This document describes the design, configuration, and operation of the OpenRouter Multi-Model Orchestration system implemented within the Antigravity automation framework. The setup leverages external Large Language Models (LLMs) via the Model Context Protocol (MCP) to automate code generation, code review, and self-correcting execution loops for KerboScript (`.ks`) and other workspace automation scripts.

---

## 1. Introduction to Multi-Model Orchestration

The Antigravity multi-model orchestration framework is designed to move beyond single-agent execution by routing specialized subtasks to the most effective models available on the OpenRouter platform. Instead of deploying complex, heavy agent orchestration frameworks (such as CrewAI or LangGraph) that require substantial computational overhead and run-time dependencies, this architecture relies on a clean, standard-based **Model Context Protocol (MCP) gateway**.

### Architectural Design
The architecture is structured as a pipeline, where the primary agent acts as a coordinator, delegating tasks to specific LLMs based on their strengths:

```
                  +-----------------------------------+
                  |         Antigravity Client        |
                  |     (Gemini Planner / Controller)  |
                  +-----------------+-----------------+
                                    |
                                    | Tool Calls (JSON-RPC)
                                    v
                  +-----------------------------------+
                  |            MCP Server             |
                  |      (openrouter_server.py)       |
                  +-----------------+-----------------+
                                    |
                                    | HTTPS POST Requests
                                    v
                  +-----------------------------------+
                  |          OpenRouter API           |
                  |          (Model Gateway)          |
                  +--------+--------+--------+--------+
                           |        |        |
         +-----------------+        |        +-----------------+
         |                          |                          |
         v                          v                          v
+------------------+       +------------------+       +------------------+
| Qwen 2.5 Coder   |       |   Gemma 4 31B    |       |  Llama 3.3 70B   |
| (qwen_reason)    |       | (deepseek_reason)|       |  (llama_reason)  |
| [Coding & Impl]  |       | [Reason & Review]|       | [Text & Drafts]  |
+------------------+       +------------------+       +------------------+
```

1. **Orchestration Client:** The primary planner (typically Gemini) coordinates tasks and invokes tools based on operational needs.
2. **MCP Server (`openrouter_server.py`):** Acts as the intermediary, exposing model-specific tools over standard I/O (stdio) and transmitting JSON-RPC request payloads.
3. **OpenRouter API:** Serves as a single unified interface to access multiple third-party API providers, managing authentication, request formatting, and model switching dynamically.
4. **Specialized Downstream Models:** The individual models receive requests, process reasoning, and return answers back through the pipeline. This approach achieves model diversity at low cost and zero local hardware overhead by leveraging free-tier APIs.

---

## 2. MCP Server Tools and Model Routing

To optimize tool call selection by the orchestration client, the MCP server exposes models as individual tools with descriptive docstrings. LLMs route tasks more reliably when tools are named after their specific capabilities rather than exposing a single generic `ask_model(model_name, prompt)` endpoint.

The server exposes three primary reasoning tools:

| Tool Name | Target OpenRouter Model ID | Core Capability / Description | Recommended Use Cases |
| :--- | :--- | :--- | :--- |
| `qwen_reason` | `qwen/qwen3-coder:free` | Software implementation, syntax formatting, and structured generation. | Writing KerboScript files, debugging compilation errors, and structuring JSON configurations. |
| `deepseek_reason` | `google/gemma-4-31b-it:free` | Advanced mathematical calculations, logical troubleshooting, and verification. | Reviewing generated KerboScript for syntax violations, verifying physics calculations, and code review. |
| `llama_reason` | `meta-llama/llama-3.3-70b-instruct:free` | Document drafting, text explanation, conceptual summaries, and semantic analysis. | Generating technical summaries, formatting workspace notes, and clarifying mission objectives. |

> [!NOTE]
> While the tool name `deepseek_reason` historically mapped to DeepSeek models, it is currently routed to the high-performing `google/gemma-4-31b-it:free` model on OpenRouter to serve as the reasoning-heavy validator for the self-correcting loop.

---

## 3. Server Configuration and Installation

The MCP server is implemented in `openrouter_server.py` using the `mcp` Python SDK (FastMCP wrapper).

### 3.1. Local Environment Configuration (`.env`)
The server reads the required authentication token from a local `.env` file situated in the workspace root directory. This file must be excluded from version control to prevent API key exposure.

**File Location:** `c:/Program Files (x86)/Steam/steamapps/common/Kerbal Space Program/Ships/Script/.env`

**File Content:**
```env
OPENROUTER_API_KEY=your_open_router_api_token_here
```

### 3.2. MCP Client Configuration (`mcp_config.json`)
To integrate the server with an MCP-compliant agent host (e.g., Cursor, VSCode Cline, or Claude Desktop), add the configuration to the host's configuration file.

There are two primary methods to install and launch the server:

#### Option A: Running via Python and `uv` (Recommended)
This approach leverages the inline PEP 723 metadata defined in the header of `openrouter_server.py`, which ensures dependencies (`mcp`, `httpx`, `python-dotenv`) are automatically installed in a sandbox environment at runtime.

```json
{
  "mcpServers": {
    "openrouter-gateway": {
      "command": "uv",
      "args": [
        "run",
        "c:/Program Files (x86)/Steam/steamapps/common/Kerbal Space Program/Ships/Script/openrouter_server.py"
      ]
    }
  }
}
```

#### Option B: Running via Standard Python
If running via standard Python, the dependencies must be installed manually in the local environment beforehand (`pip install mcp[cli] httpx python-dotenv`).

```json
{
  "mcpServers": {
    "openrouter-gateway": {
      "command": "python",
      "args": [
        "c:/Program Files (x86)/Steam/steamapps/common/Kerbal Space Program/Ships/Script/openrouter_server.py"
      ],
      "env": {
        "OPENROUTER_API_KEY": "your_open_router_api_token_here"
      }
    }
  }
}
```

### 3.3. Technical Implementation Details
- **FastMCP Instance:** The server is initialized as `FastMCP("openrouter-gateway")` and communicates via `stdio` transport.
- **Request Headers:** Requests sent to the endpoint `https://openrouter.ai/api/v1/chat/completions` include custom headers:
  - `HTTP-Referer`: Set to `https://github.com/denialbb/KOS-automation` to identify the application.
  - `X-Title`: Set to `Antigravity Orchestrator`.
- **Timeout Configuration:** A generous `timeout=120.0` is specified inside `httpx.Client()` to accommodate deep-thinking models that require extra execution time before yielding their first token.

---

## 4. Self-Correcting Orchestration Script (`orchestrate_coding.py`)

The script `orchestrate_coding.py` automates the generation of compliant KerboScript files using a self-correcting feedback loop between `qwen_reason` (as the coder) and `deepseek_reason` (routed to Gemma, as the reviewer).

### 4.1. Execution Flow
The orchestrator executes the following step-by-step logic:

```
[Start Task]
     │
     ▼
[Attempt 1: Prompt Qwen] ──> [Generate Code Block]
                                     │
                                     ▼
[Parse & Extract Code] <── [Regex Block Extraction]
     │
     ▼
[Submit Code to Gemma] ──> [Verify against Style & Syntax]
                                     │
                    ┌────────────────┴────────────────┐
                    ▼ (Rejected / Violations)         ▼ (APPROVED)
          [Generate Rejection Details]           [Save Code to File]
                    │                                 │
                    ▼                                 ▼
          [Update Qwen Prompt with Feedback]       [Exit Success]
                    │
                    ▼
          [Next Loop Attempt]
```

1. **Initial Coding Prompt Formulation:** The script constructs a prompt asking `qwen_reason` to write the script, enforcing:
   - Upper-case keywords (`LOCK`, `SET`, `PRINT`, etc.).
   - Persistent telemetry reporting via console prints.
   - Code output enclosed within a markdown code block.
2. **Code Extraction:** The generated text is parsed using a regular expression to extract the contents of the code block.
3. **Review Request:** The orchestrator packages the extracted code into a review prompt and sends it to `deepseek_reason` (Gemma). The reviewer checks for keyword casing rules, syntax, and telemetry updates.
4. **Approval Logic:**
   - If Gemma replies with `APPROVED` (or if `APPROVED` is detected on the first line), the script saves the code and terminates.
   - If Gemma detects issues, a list of structured violations is returned.
5. **Feedback Loop:** The orchestrator appends the feedback to Qwen's prompt and requests a corrected version. The loop continues for up to `max_attempts` (default: `3`).

### 4.2. Regex Parsing Details
The helper function `extract_code_block` isolates the raw script content from the model's conversational text:

```python
matches = re.findall(r"```(?:kerboscript|ks|python|json|text)?\n(.*?)\n```", text, re.DOTALL | re.IGNORECASE)
```
This expression captures the contents between the backticks, ignoring language tags (`kerboscript`, `ks`, `python`, etc.) and processing multiline responses (`re.DOTALL`).

### 4.3. Execution Example

#### CLI Command:
```powershell
python orchestrate_coding.py "Create a launch sequence that monitors altitude and locks throttle to 100% until apoapsis is above 75000m" -o DASA/launch_script.ks --attempts 3
```

#### Console Output Execution Log:
```text
[Orchestrator] Starting code generation for task: 'Create a launch sequence that monitors altitude and locks throttle to 100% until apoapsis is above 75000m'
[Orchestrator] Output path: DASA/launch_script.ks

--- Attempt 1 of 3 ---
[Orchestrator] Requesting implementation from Qwen...

[Orchestrator] Generated Code:
--------------------------------------------------
// Initial Launch Script
lock throttle to 1.0.
lock steering to up.
stage.
until apoapsis > 75000 {
    print "Current Altitude: " + altitude.
    wait 1.
}
--------------------------------------------------
[Orchestrator] Submitting code to Gemma for verification...

[Orchestrator] Reviewer Response:
REJECTION:
1. The keywords 'lock', 'to', 'stage', 'until', 'print', and 'wait' must be written in ALL CAPS. (e.g. LOCK, TO, STAGE, UNTIL, PRINT, WAIT).
2. The built-in variables 'throttle', 'steering', 'up', 'apoapsis', and 'altitude' must be in ALL CAPS.

[Orchestrator] Rejection! Feeding corrections back to Qwen...
--- Attempt 2 of 3 ---
[Orchestrator] Requesting implementation from Qwen...

[Orchestrator] Generated Code:
--------------------------------------------------
// Corrected Launch Script
LOCK THROTTLE TO 1.0.
LOCK STEERING TO UP.
STAGE.
UNTIL SHIP:APOAPSIS > 75000 {
    PRINT "Current Altitude: " + SHIP:ALTITUDE.
    WAIT 1.
}
--------------------------------------------------
[Orchestrator] Submitting code to Gemma for verification...

[Orchestrator] Reviewer Response:
APPROVED

[Orchestrator] Code APPROVED by reviewer!
[Orchestrator] Saved verified script to: c:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\Ships\Script\DASA\launch_script.ks
```
