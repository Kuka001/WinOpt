@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%=== Применение настроек Steam ===%X%
echo.
echo %Y%Эта утилита применит сохраненные настройки Steam к вашему клиенту.%X%
echo %R%Внимание: Steam будет автоматически закрыт перед заменой настроек.%X%
echo.
set "c=" & set /p c="Применить настройки? (Y/Enter=назад): "
if /i "%c%" neq "Y" exit /b

cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\steam_settings.ps1"
echo.
echo %G%Операция завершена!%X%
echo. & pause
exit /b
