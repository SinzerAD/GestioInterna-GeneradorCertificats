@echo off
rem Obre l'assistent de certificats. Fa servir PowerShell 7 si esta instal.lat.
where pwsh >nul 2>nul
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0Inicia.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Inicia.ps1"
)
