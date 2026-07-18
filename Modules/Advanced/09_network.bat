@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%Оптимизация сети...%X%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\Network.ps1"
echo.
echo %G%Сеть оптимизирована!%X%
echo %R%Перезагрузите ПК.%X%
echo. & pause
exit /b