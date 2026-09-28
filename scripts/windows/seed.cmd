@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\seed.ps1" %*
exit /b %ERRORLEVEL%
