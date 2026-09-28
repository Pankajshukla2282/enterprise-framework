@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\stop.ps1" %*
exit /b %ERRORLEVEL%
