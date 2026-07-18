@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\Services.ps1"
pause
exit /b
