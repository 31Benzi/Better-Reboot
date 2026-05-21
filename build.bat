@echo off
setlocal enabledelayedexpansion

:: Better Reboot Launcher - All-in-one Build Script
:: This script checks for requirements, installs dependencies, and builds the project.

set "VERSION=1.3.0"
title Better Reboot Launcher Builder v%VERSION%

echo ================================================================
echo           Better Reboot Launcher 32.11 - Build System
echo ================================================================
echo.

:: --- 1. TOOL CHECK ---
echo [STEP 1] Checking for required tools...

:: Check Git
where git >nul 2>nul
if %errorlevel% == 0 goto :GitOk
if exist "C:\Program Files\Git\cmd\git.exe" (
    set "PATH=!PATH!;C:\Program Files\Git\cmd"
    echo [+] Git found in default location.
    goto :GitOk
)

echo [*] Git is missing. Downloading and installing...
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
set "PATH=!PATH!;C:\Program Files\Git\cmd"
echo [+] Git installed.

:GitOk
echo [+] Git is available.

:: Check Node.js
where node >nul 2>nul
if %errorlevel% == 0 goto :NodeOk
if exist "C:\Program Files\nodejs\node.exe" (
    set "PATH=!PATH!;C:\Program Files\nodejs"
    echo [+] Node.js found in default location.
    goto :NodeOk
)

echo [*] Node.js is missing. Downloading and installing...
winget install --id OpenJS.NodeJS -e --silent --accept-source-agreements --accept-package-agreements
set "PATH=!PATH!;C:\Program Files\nodejs"
echo [+] Node.js installed.

:NodeOk
echo [+] Node.js is available.

:: Check Flutter
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "PATH=!PATH!;%USERPROFILE%\flutter\bin"
)

where flutter >nul 2>nul
if %errorlevel% == 0 goto :FlutterOk

echo [*] Flutter SDK is missing or outdated. 
echo [*] Downloading Flutter SDK v3.41.9 (this may take a few minutes)...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.41.9-stable.zip' -OutFile 'flutter_sdk.zip'; echo '[*] Extracting Flutter...'; if (Test-Path '%USERPROFILE%\flutter') { Remove-Item -Recurse -Force '%USERPROFILE%\flutter' }; Expand-Archive 'flutter_sdk.zip' -DestinationPath '%USERPROFILE%'; Remove-Item 'flutter_sdk.zip' }"
set "PATH=!PATH!;%USERPROFILE%\flutter\bin"
echo [+] Flutter installed to %USERPROFILE%\flutter

:FlutterOk
echo [+] Flutter is available.

:: --- 2. DEPENDENCY DOWNLOAD ---
echo.
echo [STEP 2] Downloading project dependencies...

:: Auth Backend
if not exist "auth_backend\package.json" goto :SkipAuthDeps
echo [*] Installing Node.js packages for auth_backend...
pushd auth_backend
call npm install
popd
:SkipAuthDeps

:: Flutter Components (Common, CLI, Server Browser, GUI)
set "COMPONENTS=common cli server_browser_backend gui"
for %%c in (%COMPONENTS%) do (
    if exist "%%c\pubspec.yaml" (
        echo [*] Fetching Flutter packages for %%c...
        pushd %%c
        call flutter pub get
        popd
    )
)

:: --- 3. SYNC BACKEND ASSETS ---
echo.
echo [STEP 3] Syncing backend assets into GUI...
call "%~dp0scripts\sync-backend-assets.bat"
if %errorlevel% neq 0 goto :BuildFailed

:: --- 4. BUILDING ---
echo.
echo [STEP 4] Building executables...

:: Build GUI Launcher
if not exist "gui\lib\main.dart" goto :SkipGuiBuild
echo [*] Building Launcher GUI (Windows)...
pushd gui
call flutter build windows --release
if %errorlevel% neq 0 goto :BuildFailed
popd
:SkipGuiBuild

echo.
echo ================================================================
echo [SUCCESS] Build Process Completed!
echo ================================================================
echo.
echo Generated files:
echo  - Launcher GUI: %~dp0gui\build\windows\x64\runner\Release\Better Reboot Launcher.exe
echo.
echo Optional: run auth backend with Node:  cd auth_backend ^&^& npm start
echo.
echo Note: You can find the main launcher in the release folder listed above.
echo.

set "LAUNCHER_EXE=%~dp0gui\build\windows\x64\runner\Release\Better Reboot Launcher.exe"
if exist "!LAUNCHER_EXE!" (
    echo [*] Starting Better Reboot Launcher...
    start "" "!LAUNCHER_EXE!"
)

pause
exit /b 0

:BuildFailed
echo.
echo [ERROR] Flutter build failed!
echo [TIP] Ensure "Desktop development with C++" is installed in Visual Studio.
echo [TIP] Run 'flutter doctor' to check for configuration issues.
popd
pause
exit /b 1
