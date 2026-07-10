@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:wu_menu
cls
echo %Y%=== Обновления Windows ===%X%
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" >nul 2>&1
if %errorlevel% neq 0 (
    echo %R%[!] Внимание: Этот модуль работает только в Безопасном режиме!%X%
    echo %Y%Вы запустили оптимизатор в обычном режиме Windows.%X%
    echo.
    echo Для отключения или включения обновлений Windows (Windows Update)
    echo требуется обязательный перезапуск системы в Безопасном режиме.
    echo.
    echo %Y%Инструкция по переходу:%X%
    echo 1. В открывшемся окне msconfig перейдите во вкладку Загрузка [Boot].
    echo 2. Включите Безопасный режим [Safe boot] и выберите Минимальная [Minimal].
    echo 3. Нажмите ОК и перезагрузите компьютер.
    echo.
    echo Нажмите любую клавишу, чтобы открыть msconfig и подготовить систему...
    pause >nul
    start msconfig
    exit /b
)
echo %G%Безопасный режим обнаружен.%X%
echo.
echo 1. ОТКЛЮЧИТЬ обновления
echo 2. ВКЛЮЧИТЬ обновления
echo 0. Назад
echo.
set "c=" & set /p c="Выбор: "
if "%c%"=="0" exit /b
if "%c%"=="1" set "WU_ARG=-Action Disable" & goto run_wu_switcher
if "%c%"=="2" set "WU_ARG=-Action Enable" & goto run_wu_switcher
goto wu_menu

:run_wu_switcher
cls
echo %Y%Запуск скрипта обновлений...%X%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\WindowsUpdate.ps1" %WU_ARG%
echo.
echo %G%Операция завершена!%X%
echo %Y%[!] Уберите галочку "Безопасный режим" в msconfig перед перезагрузкой!%X%
echo. & pause & start msconfig
exit /b