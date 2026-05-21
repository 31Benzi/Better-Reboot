@echo off
call "%~dp0..\scripts\sync-backend-assets.bat"
if %errorlevel% neq 0 exit /b %errorlevel%
flutter_distributor package --platform windows --target exe
