@echo off
REM Obsidian Google Drive Sync - Start Script for Windows
REM Usage: start_sync.bat [--sync|--daemon|--status]

REM Change to script directory
cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Run the sync script
python obsidian_sync.py %*

REM Keep window open if there's an error
if %errorlevel% neq 0 (
    echo.
    echo Press any key to exit...
    pause
)
