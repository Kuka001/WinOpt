@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%Настройка Win32PrioritySeparation (0x18)...%X%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 18 /f >nul 2>&1
if %errorlevel% equ 0 (echo %G%Готово!%X%) else (call "%~dp0..\..\Core\helpers.bat" show_fail)
echo. & pause
exit /b