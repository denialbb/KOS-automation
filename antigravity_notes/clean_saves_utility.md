# KSP Save Cleanup Utility

Created a Python utility script [clean_saves.py](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/clean_saves.py) to manage save files in the KSP save game directories, along with a batch wrapper [clean_saves.bat](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/clean_saves.bat).

## Rules & Behavior

1. **Auto-timestamped Quicksaves / Autosaves**:
   - Matches pattern: `^Y\d+D\d+_\d+_(QS|AS)_`
   - These are cleaned up automatically.
2. **Protected Saves**:
   - `persistent.sfs` (and its `.loadmeta`)
   - `quicksave.sfs` (and its `.loadmeta`)
   - These standard KSP system files are ignored and preserved to prevent breaking KSP main menu loads.
3. **Named Saves**:
   - Sorted by modification date (newest first).
   - Keeps only the latest 3.
   - Deletes older named saves along with their accompanying `.loadmeta` files.
4. **Dry Run Mode**:
   - The script runs in dry-run mode by default. Run with `--apply` to perform actual file deletions.

## Batch Wrapper (clean_saves.bat)

The batch file runs the dry-run scan automatically, then presents an interactive prompt to the user:
- **Option 1**: Performs the cleanup (`--apply`).
- **Option 2**: Exits safely.
- Alternatively, running `clean_saves.bat --apply` or `clean_saves.bat -a` skips the prompt and applies the changes directly.

