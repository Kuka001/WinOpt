@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%Настройка прерываний системного таймера...%X%
echo Отключение Dynamic Tick и настройка SerializeTimerExpiration...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "SerializeTimerExpiration" /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 (echo %G%Готово!%X% & echo %R%Перезагрузите ПК.%X%) else (call "%~dp0..\..\Core\helpers.bat" show_fail)
echo. & pause
exit /b