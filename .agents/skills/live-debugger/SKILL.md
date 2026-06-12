---
name: live-debugger
description: >-
  Automates live debugging of kOS scripts by writing test scripts and launching a background subagent to monitor log files in real-time, timing out after 5 minutes.
---

# kOS Live Debugger

## Overview
This instruction-only skill directs the agent on how to interactively debug kOS scripts. It dictates a workflow where the agent writes a test wrapper script, instructs the user to run it in the KSP terminal, and concurrently spawns a subagent that polls the active log file to catch debugging output in real-time.

## Dependencies
*   [kos-debug](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/.agents/skills/kos-debug/SKILL.md) - If the live test crashes instead of producing expected output, fall back to this skill to diagnose `KSP.log`.

## Quick Start
To trigger this skill, the user can prompt:
> *"Use the `live-debugger` skill to help me debug the science loop."*

## Workflow

### 1. Identify the Target
Determine which script or feature needs to be tested and what log output you are looking for. Ask the user which log file should be watched (e.g., `0:/logs/log.txt` or `KSP.log`) if it is not obvious.

### 2. Create the Test Wrapper
Create a minimal test script in the `Tests/` directory that imports and runs the target feature.
*   Example: `Tests/test_feature.ks`

### 3. Launch the Background Watcher
Use the `define_subagent` tool to create a subagent named `log_watcher` (or similar) with the following system prompt logic:

```text
You are a Log Watcher agent.
Your job is to monitor the log file `{Target_Log_File}`.
Initialize a counter `LOCAL loops IS 0`.
Use the `schedule` tool to wait for 3 seconds. When you wake up:
1. Increment your loop counter.
2. If the counter > 100 (which is 5 minutes), report to the parent agent that the test timed out without seeing the expected output, and terminate your task.
3. Otherwise, use `run_command` with `WaitMsBeforeAsync: 5000` to run:
   `powershell -Command "Get-Content -Path '{Target_Log_File}' -Tail 30"`
   (Do NOT use the `-Wait` flag.)
4. When you see output containing `{Expected_Debug_Strings}`, report the findings back to the parent agent using `send_message`. Include a summary of the events logged and terminate your task.
5. If you don't see the expected output, schedule another 3-second wait and repeat.
```
Invoke this subagent immediately using `invoke_subagent`.

### 4. Instruct the User
Prompt the user to execute the test script in their KSP terminal (e.g., `RUNPATH("0:/Tests/test_feature.ks").`) and inform them that the background subagent is actively watching the logs.

### 5. Iterate
Wait for the subagent to report back. Analyze the results, fix any bugs in the underlying scripts, and repeat the workflow until the feature works perfectly.

## Common Mistakes
*   **Using `-Wait` in Powershell**: Do not use `Get-Content -Wait` in the subagent's `run_command` as it can hang indefinitely. Always use a polling approach with the `schedule` tool.
*   **Forgetting to Timeout**: Always ensure the subagent has a loop limit (e.g., 100 loops of 3s) so it doesn't run forever if the KSP script crashes early.
