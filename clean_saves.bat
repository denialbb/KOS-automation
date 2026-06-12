@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo ===================================================
echo             KSP Save Game Cleaner
echo ===================================================
echo.

if "%~1"=="--apply" (
    echo [RUNNING] Applying save game cleanup...
    python clean_saves.py --apply
    goto end
)

if "%~1"=="-a" (
    echo [RUNNING] Applying save game cleanup...
    python clean_saves.py --apply
    goto end
)

echo [RUNNING] Executing Dry-Run scan first...
echo.
python clean_saves.py

echo.
echo ===================================================
echo Options:
echo   1. Perform cleanup (Apply changes)
echo   2. Exit
echo ===================================================
set /p choice="Enter option (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo [RUNNING] Applying save game cleanup...
    python clean_saves.py --apply
) else (
    echo Exiting without changes.
)

:end
echo.
pause
