@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:: Проверка прав Администратора через реестр (не зависит от работы сетевых служб)
reg query "HKU\S-1-5-19" >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo %Y%=== Внимание! ===%X%
    echo Скрипт должен быть запущен от имени Администратора.
    echo Пожалуйста, запустите этот файл правой кнопкой мыши -> "Запуск от имени администратора".
    echo.
    pause
    exit /b
)

:: Переход в папку со скриптом (защита от сброса рабочей директории в System32 при запуске от админа)
cd /d "%~dp0" >nul 2>&1

:vbs_setup
cls
echo %Y%=== Настройка VBS для Faceit ===%X%
echo.
echo 1. %G%[РЕКОМЕНДУЕТСЯ]%X% Оптимальный режим (VBS вкл, HVCI выкл)
echo    * Повышает FPS и снижает инпут-лаг.
echo    * Внимание: некоторым аккаунтам Faceit AC может принудительно требовать HVCI!
echo 2. Проверить текущий статус VBS (Реальный запуск служб)
echo 3. Включить всё обратно (VBS + HVCI)
echo 4. Полностью отключить VBS + HVCI (Максимальный FPS в других играх)
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" goto vbs_optimal
if "%c%"=="2" goto vbs_status
if "%c%"=="3" goto vbs_full_enable
if "%c%"=="4" goto vbs_disable
goto vbs_setup

:vbs_status
cls
echo %Y%=== Текущий статус VBS ===%X%
:: Запрос фактического состояния системы через WMI класс DeviceGuard
powershell -NoProfile -Command "$dg = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -EA 0; if ($dg) { $vbs = switch($dg.VirtualizationBasedSecurityStatus){0{'Выключен'}1{'Включен в реестре, но не запущен (проверьте BIOS)'}2{'Запущен и активен'}default{'Неизвестно'}}; $hvci = if ($dg.SecurityServicesRunning -contains 2){'Запущен (Memory Integrity активна)'}else{'Выключен'}; Write-Host 'VBS статус: ' $vbs; Write-Host 'HVCI статус: ' $hvci } else { Write-Host 'Не удалось получить данные о DeviceGuard (служба отключена или урезанная ОС).' }"
echo. & pause
goto vbs_setup

:vbs_optimal
cls
echo %Y%=== Оптимальный режим: VBS вкл, HVCI выкл ===%X%
bcdedit /set "{current}" hypervisorlaunchtype auto >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
echo %G%Готово! Перезагрузите ПК.%X%
echo. & pause
goto vbs_setup

:vbs_full_enable
cls
echo %Y%=== Полное включение VBS + HVCI ===%X%
bcdedit /set "{current}" hypervisorlaunchtype auto >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 1 /f >nul 2>&1
echo %G%Готово! Перезагрузите ПК.%X%
echo. & pause
goto vbs_setup

:vbs_disable
cls
echo %Y%=== Полное отключение VBS и HVCI ===%X%
bcdedit /set "{current}" hypervisorlaunchtype off >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
echo %G%Готово! Перезагрузите ПК.%X%
echo. & pause
goto vbs_setup