@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:: Надежная проверка прав администратора (не зависит от состояния сетевых служб)
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo %Y%=== Ошибка ===%X%
    echo Для применения настроек требуются права администратора.
    echo Пожалуйста, запустите скрипт от имени Администратора.
    echo.
    pause
    exit /b
)

:memory_ntfs
cls
echo %Y%=== Оптимизация памяти и NTFS ===%X%
echo.
echo 1. Применить оптимизации
echo 0. Вернуть по умолчанию
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    :: DisablePagingExecutive - запрет сброса ядра и драйверов в файл подкачки
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
    
    :: Отключение обновления времени последнего доступа к файлам
    fsutil behavior set disablelastaccess 1 >nul 2>&1
    
    :: Отключение создания коротких имен 8.3
    fsutil behavior set disable8dot3 1 >nul 2>&1
    
    echo.
    echo %G%Применено успешно!%X%
    echo %Y%Внимание: Настройки вступят в силу после перезагрузки ПК.%X%
    echo.
    pause & goto memory_ntfs
)
if "%c%"=="0" (
    :: Возврат по умолчанию для DisablePagingExecutive
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1
    
    :: Возврат к системному управлению временем доступа (2 - System Managed)
    fsutil behavior set disablelastaccess 2 >nul 2>&1
    
    :: Возврат к стандартному поведению 8.3 (2 - управление на уровне тома)
    fsutil behavior set disable8dot3 2 >nul 2>&1
    
    echo.
    echo %G%Параметры восстановлены!%X%
    echo %Y%Внимание: Настройки вступят в силу после перезагрузки ПК.%X%
    echo.
    pause & goto memory_ntfs
)
goto memory_ntfs