@echo off
setlocal enabledelayedexpansion

set "ROOT=%~dp0.."
set "SRC=%ROOT%\auth_backend"
set "DST=%ROOT%\gui\assets\backend"

if not exist "%SRC%\index.js" (
    echo [ERROR] auth_backend not found at %SRC%
    exit /b 1
)

if not exist "%DST%" mkdir "%DST%"

set "DIRS=CloudStorage Config profiles public responses"
set "ERR=0"

for %%D in (%DIRS%) do (
    if not exist "%SRC%\%%D" (
        echo [WARN] Missing source folder: %%D
        set "ERR=1"
    ) else (
        echo [*] Syncing %%D ...
        robocopy "%SRC%\%%D" "%DST%\%%D" /MIR /NFL /NDL /NJH /NJS /nc /ns /np >nul
        if errorlevel 8 set "ERR=1"
    )
)

if "%ERR%"=="1" (
    echo [ERROR] Backend asset sync failed.
    exit /b 1
)

echo [+] Backend assets synced to gui\assets\backend
exit /b 0
