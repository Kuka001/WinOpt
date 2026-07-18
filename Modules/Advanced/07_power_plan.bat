@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%Настройка электропитания...%X%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\PowerPlan.ps1"
echo.
echo %G%Электропитание настроено.%X%
echo. & pause
exit /b