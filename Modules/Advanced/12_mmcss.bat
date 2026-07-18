@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:disable_mmcss
cls
echo %Y%=== Настройка MMCSS ===%X%
echo.
echo %Y%MMCSS (Multimedia Class Scheduler) приоритизирует аудио-потоки.%X%
echo %Y%Отключение нужно для CS2, но может вызвать заикание звука при высокой нагрузке CPU.%X%
echo %Y%Для CS2 с WASAPI-аудио рекомендуется оставить включённой.%X%
echo.
echo 1. Отключить MMCSS ДЛЯ CS2 ^(%R%риск аудио-артефактов%X%^)
echo 0. Включить MMCSS ТОЛЬКО ЕСЛИ ПОЯВИЛИСЬ ЗАИКАНИЯ ЗВУКОВ ^(%G%по умолчанию%X%^)
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    cls & echo Отключение MMCSS...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
    net stop MMCSS /y >nul 2>&1
    echo %G%MMCSS отключена.%X% & echo. & pause & goto disable_mmcss
)
if "%c%"=="0" (
    cls & echo Включение MMCSS...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
    net start MMCSS >nul 2>&1
    echo %G%MMCSS включена (по умолчанию).%X% & echo. & pause & goto disable_mmcss
)
goto disable_mmcss