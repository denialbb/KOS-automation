#!/usr/bin/env python3
"""
KSP Save Game Cleanup Utility
Cleans up automatic timestamped quicksaves and keeps only the latest 3 named saves.
"""

import os
import re
import sys
import argparse
import datetime
from pathlib import Path

# Patterns
# Auto-timestamped quicksaves/autosaves like: Y1D013_045306_AS_Minmus KOS Probe-3.sfs
AUTO_SAVE_PATTERN = re.compile(r'^Y\d+D\d+_\d+_(QS|AS)_', re.IGNORECASE)

# Standard KSP system files to protect
PROTECTED_SAVES = {'persistent.sfs', 'quicksave.sfs'}

def clean_save_folder(save_path: Path, dry_run: bool):
    print(f"\nScanning save folder: {save_path.name}")
    
    if not save_path.exists():
        print(f"Directory {save_path} does not exist.")
        return

    # Find all .sfs files
    sfs_files = list(save_path.glob("*.sfs"))
    if not sfs_files:
        print("No .sfs save files found.")
        return

    auto_saves_to_delete = []
    named_saves = []

    for f in sfs_files:
        name_lower = f.name.lower()
        if name_lower in PROTECTED_SAVES:
            # Always keep persistent.sfs and quicksave.sfs
            continue
        
        # Check if it matches the automatic timestamp pattern
        if AUTO_SAVE_PATTERN.match(f.name):
            auto_saves_to_delete.append(f)
        else:
            named_saves.append(f)

    # Sort named saves by modification time (newest first)
    named_saves.sort(key=lambda x: x.stat().st_mtime, reverse=True)

    keep_named = named_saves[:3]
    delete_named = named_saves[3:]

    # Summarize plan
    print(f"  Total save files found: {len(sfs_files)}")
    print(f"  Automatic timestamped saves to delete: {len(auto_saves_to_delete)}")
    print(f"  Named saves found: {len(named_saves)}")
    
    print("\n  [KEEPING] Named saves (latest 3):")
    for f in keep_named:
        mtime = f.stat().st_mtime
        time_str = datetime.datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
        print(f"    - {f.name} (Modified: {time_str})")

    to_delete = auto_saves_to_delete + delete_named
    
    if not to_delete:
        print("\n  No files need to be deleted.")
        return

    print(f"\n  [DELETING] {len(to_delete)} save files (and their matching .loadmeta files):")
    for f in to_delete:
        mtime = f.stat().st_mtime
        time_str = datetime.datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
        print(f"    - {f.name} (Modified: {time_str})")

    if dry_run:
        print("\n  *** DRY RUN MODE *** - No files were deleted. Run with --apply to perform deletion.")
    else:
        print("\n  Performing deletion...")
        deleted_count = 0
        for f in to_delete:
            # Delete the .sfs file
            try:
                f.unlink()
                deleted_count += 1
            except Exception as e:
                print(f"    Error deleting {f.name}: {e}")
            
            # Delete corresponding .loadmeta file if it exists
            meta_file = f.with_suffix(".loadmeta")
            if meta_file.exists():
                try:
                    meta_file.unlink()
                except Exception as e:
                    print(f"    Error deleting metadata {meta_file.name}: {e}")
        print(f"  Successfully deleted {deleted_count} files.")

def main():
    parser = argparse.ArgumentParser(description="Clean up KSP save games folder.")
    parser.add_argument("--apply", action="store_true", help="Perform the actual file deletion.")
    parser.add_argument("--dir", type=str, help="Path to KSP saves directory. Defaults to relative path detection.")
    
    args = parser.parse_args()

    # Find the saves directory
    if args.dir:
        saves_dir = Path(args.dir)
    else:
        # Default: script is in Ships/Script, saves is at ../../saves
        saves_dir = Path(__file__).resolve().parent.parent.parent / "saves"

    if not saves_dir.exists() or not saves_dir.is_dir():
        print(f"Error: KSP saves directory not found at {saves_dir.resolve()}")
        sys.exit(1)

    print(f"KSP saves directory: {saves_dir.resolve()}")
    
    # Iterate through each subfolder in saves/
    for item in saves_dir.iterdir():
        if item.is_dir() and item.name.lower() not in {"scenarios", "training"}:
            clean_save_folder(item, dry_run=not args.apply)

if __name__ == "__main__":
    main()
