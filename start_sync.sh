#!/bin/bash

# Obsidian Google Drive Sync - Start Script
# Usage: ./start_sync.sh [--sync|--daemon|--status]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed"
    exit 1
fi

# Run the sync script
python3 obsidian_sync.py "$@"
