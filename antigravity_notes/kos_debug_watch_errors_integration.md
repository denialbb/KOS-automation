# Note: Integration of watch_kos_errors.py into kos-debug Skill

We have modified the `kos-debug` skill to utilize the Python log parser script `watch_kos_errors.py` instead of raw file tails or PowerShell-based commands.

## Rationale
- **Structured Error Event Stream:** The Python script parses logs and outputs structured, deduplicated NDJSON error event objects, including surrounding context lines and stack traces.
- **Improved Performance:** Avoids parsing the entire large `KSP.log` via less efficient shell command tools, offering options like `--tail-lines 200` and `--extract-all`.
- **Real-Time Streaming:** The script supports `--watch` mode, allowing developers/agents to tail and stream new log outputs in real-time.
