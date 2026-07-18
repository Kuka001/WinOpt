@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%=== Affinity и MSI Mode (Device Tweaker) ===%X%
echo.
echo %Y%Интерактивная утилита для настройки:%X%
echo  - CPU Affinity для устройств (привязка к ядрам)
echo  - MSI Mode (Message Signaled Interrupts)
echo  - Interrupt Priority
echo.
echo %R%Требует перезагрузки после применения настроек.%X%
echo.
set "c=" & set /p c="Запустить Device Tweaker? (Y/Enter=назад): "
if /i "%c%" neq "Y" exit /b

cls
echo Запуск Device Tweaker...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\device_tweaker.ps1"
echo.
echo %G%Device Tweaker завершён.%X%
echo %R%Перезагрузите ПК для применения изменений.%X%
echo. & pause
exit /b
