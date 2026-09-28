@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\status.ps1" %*
exit /b %ERRORLEVEL%
