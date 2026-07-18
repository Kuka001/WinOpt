@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

:bitlocker_menu
cls
echo %Y%=== Настройка BitLocker ===%X%
echo.
echo 1. Глобальное отключение BitLocker
echo 0. BitLocker по умолчанию
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    cls & echo Отключение BitLocker...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v PreventDeviceEncryption /t REG_DWORD /d 1 /f >nul 2>&1
    sc config BDESVC start= disabled >nul 2>&1
    if !errorlevel! equ 0 (call "..\..\Core\helpers.bat" show_ok & echo %R%Убедитесь что диск расшифрован!%X%) else (call "..\..\Core\helpers.bat" show_fail)
    echo. & pause & goto bitlocker_menu
)
if "%c%"=="0" (
    cls & echo Возврат BitLocker...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v PreventDeviceEncryption /t REG_DWORD /d 0 /f >nul 2>&1
    sc config BDESVC start= demand >nul 2>&1
    if !errorlevel! equ 0 (call "..\..\Core\helpers.bat" show_ok) else (call "..\..\Core\helpers.bat" show_fail)
    echo. & pause & goto bitlocker_menu
)
goto bitlocker_menu