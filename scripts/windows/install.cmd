@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\install-windows.ps1" %*
exit /b %ERRORLEVEL%
