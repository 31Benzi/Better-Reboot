@echo off
setlocal enabledelayedexpansion

title Better Reboot Launcher

call "%~dp0scripts\sync-backend-assets.bat"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to sync backend assets.
    pause
    exit /b 1
)

set "LAUNCHER_EXE=%~dp0gui\build\windows\x64\runner\Release\Better Reboot Launcher.exe"

if exist "%LAUNCHER_EXE%" (
    echo Starting Better Reboot Launcher...
    start "" "%LAUNCHER_EXE%"
    exit /b 0
)

:: Release build missing — run in development mode if Flutter is available
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "PATH=%PATH%;%USERPROFILE%\flutter\bin"
)

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Launcher not found.
    echo.
    echo Build it first:  build.bat
    echo Expected file: %LAUNCHER_EXE%
    pause
    exit /b 1
)

echo Release build not found. Starting in development mode...
pushd "%~dp0gui"
call flutter run -d windows
set "ERR=!errorlevel!"
popd
exit /b !ERR!
