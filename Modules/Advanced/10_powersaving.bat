@echo off
setlocal EnableDelayedExpansion

:: Проверка прав администратора через команду openfiles
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Этот скрипт требует прав администратора.
    echo Пожалуйста, запустите данный файл от имени Администратора.
    echo.
    pause
    exit /b 1
)

:: Подключение инициализации окружения, если файл существует
if exist "%~dp0..\..\Core\init.bat" (
    call "%~dp0..\..\Core\init.bat"
)

cls

:: Вывод сообщения с поддержкой цветов из init.bat (или стандартный текст в качестве запасного варианта)
if not "%Y%"=="" (
    echo %Y%Отключение энергосбережения устройств... ПОДОЖДИТЕ, ЭТО ЗАНИМАЕТ ВРЕМЯ.%X%
) else (
    echo Отключение энергосбережения устройств... ПОДОЖДИТЕ, ЭТО ЗАНИМАЕТ ВРЕМЯ.
)

:: Запуск PowerShell-скрипта
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\PowerSaving.ps1"

echo.
if not "%G%"=="" (
    echo %G%Энергосбережение отключено.%X%
    echo %R%Перезагрузите ПК.%X%
) else (
    echo [УСПЕШНО] Энергосбережение отключено.
    echo [ВНИМАНИЕ] Рекомендуется перезагрузить ПК для применения всех изменений.
)

echo. & pause
exit /b 0