@echo off
title Grinding Forever - Import saved activity
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0activity-importer\Import-ForeverActivity.ps1"
set "GF_IMPORT_EXIT=%ERRORLEVEL%"
echo.
echo Press any key to close this window.
pause >nul
exit /b %GF_IMPORT_EXIT%
