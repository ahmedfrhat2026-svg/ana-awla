#!/usr/bin/env python3
"""
Check if Obsidian Sync setup is correct.
Run this to verify everything is installed and configured.
"""

import sys
import os
from pathlib import Path

print("\n" + "=" * 60)
print("Obsidian Sync Setup Checker")
print("=" * 60 + "\n")

checks = {
    '✅ Python version': None,
    '✅ google-auth-oauthlib': None,
    '✅ google-api-python-client': None,
    '✅ Google Drive credentials': None,
    '✅ Obsidian vault path': None,
}

# Check Python version
try:
    if sys.version_info >= (3, 8):
        checks['✅ Python version'] = f"✅ {sys.version}"
    else:
        checks['✅ Python version'] = f"❌ Python 3.8+ required, got {sys.version}"
except:
    checks['✅ Python version'] = "❌ Failed to check Python version"

# Check google-auth-oauthlib
try:
    import google_auth_oauthlib
    checks['✅ google-auth-oauthlib'] = "✅ Installed"
except ImportError:
    checks['✅ google-auth-oauthlib'] = "❌ Not installed (run: pip install -r requirements.txt)"

# Check google-api-python-client
try:
    import googleapiclient
    checks['✅ google-api-python-client'] = "✅ Installed"
except ImportError:
    checks['✅ google-api-python-client'] = "❌ Not installed (run: pip install -r requirements.txt)"

# Check credentials.json
creds_file = Path(__file__).parent / 'credentials.json'
if creds_file.exists():
    checks['✅ Google Drive credentials'] = f"✅ Found at {creds_file}"
else:
    checks['✅ Google Drive credentials'] = f"❌ Not found at {creds_file}\n   Follow setup guide to get credentials.json"

# Check Obsidian vault
config_dir = Path.home() / '.obsidian_sync'
config_file = config_dir / 'config.json'
if config_file.exists():
    import json
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        vault_path = config.get('obsidian_vault_path')
        if vault_path and Path(vault_path).exists():
            checks['✅ Obsidian vault path'] = f"✅ {vault_path}"
        else:
            checks['✅ Obsidian vault path'] = f"⚠️  Configured but not found: {vault_path}"
    except:
        checks['✅ Obsidian vault path'] = "❌ Error reading config"
else:
    checks['✅ Obsidian vault path'] = "⚠️  Not configured yet (run: python obsidian_sync.py --setup)"

# Print results
for check_name, status in checks.items():
    if status:
        print(f"{check_name}")
        print(f"   {status}\n")

# Summary
print("=" * 60)
print("Summary")
print("=" * 60)

failed = [s for s in checks.values() if s and ('❌' in s or '⚠️' in s)]
if not failed:
    print("✅ All checks passed! Ready to use:\n")
    print("   python obsidian_sync.py --daemon")
elif any('❌' in s for s in failed):
    print("❌ Some checks failed. Please fix the issues above.")
    sys.exit(1)
else:
    print("⚠️  Some warnings above. You can still try using the tool.")

print("\n" + "=" * 60 + "\n")
