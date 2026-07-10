@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\Services.ps1"
pause
exit /b
