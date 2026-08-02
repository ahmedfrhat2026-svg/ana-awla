#!/usr/bin/env python3
"""
Example usage of the Obsidian Sync library.
You can import and use the sync classes in your own code.
"""

from obsidian_sync import ObsidianSync, ObsidianSyncConfig
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

# Example 1: One-time sync
print("📌 Example 1: One-time sync\n")
sync = ObsidianSync()
result = sync.perform_sync()
print(f"Result: {result}\n")

# Example 2: Show sync status
print("📌 Example 2: Show sync status\n")
sync.show_status()

# Example 3: Custom sync interval (run daemon with custom interval)
print("📌 Example 3: Run daemon with custom interval (10 minutes)\n")
# To change the interval, modify SYNC_INTERVAL in obsidian_sync.py
# Or use the command line: python obsidian_sync.py --daemon

# Example 4: Access configuration
print("📌 Example 4: Access configuration\n")
config = ObsidianSyncConfig()
vault_path = config.get('obsidian_vault_path')
print(f"Obsidian vault path: {vault_path}")
print(f"Sync extensions: {config.get('sync_extensions')}")
print(f"Excluded patterns: {config.get('exclude_patterns')}")

# Example 5: Get local files
print("\n📌 Example 5: Get local files\n")
sync = ObsidianSync()
local_files = sync.get_local_files()
print(f"Total local files: {len(local_files)}")
for path in sorted(local_files.keys())[:5]:  # Show first 5
    print(f"  - {path}")
if len(local_files) > 5:
    print(f"  ... and {len(local_files) - 5} more")
