@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\start.ps1" %*
exit /b %ERRORLEVEL%
