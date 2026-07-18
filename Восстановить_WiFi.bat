@echo off
cd /d "%~dp0"
chcp 1251 >nul
title Восстановление Wi-Fi и беспроводных сетей

:: Надежная проверка на права Администратора
fsutil dirty query %systemdrive% >nul 2>&1
if %errorLevel% equ 0 goto :skip_admin
echo Запрос прав Администратора для восстановления Wi-Fi...
set "MY_DP0=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList ('/c cd /d ' + [char]34 + $env:MY_DP0 + [char]34 + ' && Восстановить_WiFi.bat') -Verb RunAs"
exit /b
:skip_admin

cls
echo ===========================================================
echo       ВОССТАНОВЛЕНИЕ РАБОТЫ И ОТОБРАЖЕНИЯ WI-FI МОДУЛЯ
echo ===========================================================
echo.
echo Этот скрипт полностью сбросит и восстановит все службы,
echo отвечающие за Wi-Fi, а также вернет параметры сетевой карты
echo к заводским настройкам по умолчанию (исправит ошибку Код 10).
echo.
echo Нажмите любую клавишу для начала восстановления...
pause >nul

echo.
echo [1/4] Настройка и запуск служб Windows...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Service -Name WlanSvc -StartupType Automatic -EA 0; Set-Service -Name NlaSvc -StartupType Automatic -EA 0; Set-Service -Name EapHost -StartupType Manual -EA 0; Set-Service -Name wcncsvc -StartupType Manual -EA 0; Set-Service -Name WwanSvc -StartupType Manual -EA 0; Set-Service -Name dot3svc -StartupType Manual -EA 0; Set-Service -Name WFDSConMgrSvc -StartupType Manual -EA 0; Set-Service -Name netman -StartupType Manual -EA 0; Set-Service -Name netprofm -StartupType Manual -EA 0; Start-Service -Name WlanSvc -EA 0; Start-Service -Name NlaSvc -EA 0; Start-Service -Name netman -EA 0; Start-Service -Name netprofm -EA 0;"

echo.
echo [2/4] Сброс параметров реестра сетевого адаптера Wi-Fi...
echo       (Удаление несовместимых твиков оптимизации)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$classKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}'; $subkeys = Get-ChildItem $classKey -EA SilentlyContinue; foreach ($subkey in $subkeys) { $path = $subkey.PSPath; $desc = (Get-ItemProperty $path -Name 'DriverDesc' -EA 0).DriverDesc; if ($desc -like '*Intel*Wi-Fi*' -or $desc -like '*AX200*' -or $desc -like '*Wireless*' -or $desc -like '*Wi-Fi*' -or $desc -like '*802.11*') { Write-Host '  Найдено устройство:' $desc -ForegroundColor Cyan; $valsToDelete = @('HwOption', 'HwOptionV2', 'HwOptionV3', 'ASPM', 'CLKREQ', 'EnableAspm', 'EnablePowerManagement', 'EnablePME', 'EnableModernStandby', '*SelectiveSuspend', '*DeviceSleepOnDisconnect', '*WakeOnMagicPacket', '*WakeOnPattern', '*NicAutoPowerSaver', 'EEELinkAdvertisement', 'WakeFromS5', 'WakeOnLink', 'EnableETW', '*EEE', 'DMACoalescing', 'ReduceSpeedOnPowerDown', '*EnableDynamicPowerGating', 'EnableD3ColdInS0', 'AdvancedEEE', 'EEEPlus', 'DynamicLTR', 'EnableGreenEthernet', 'GigaLite', 'PowerDownPll', 'PowerSavingMode', 'WolShutdownLinkSpeed', 'LTROBFF', 'S0MgcPkt', 'S5WakeOnLan'); foreach ($val in $valsToDelete) { if ((Get-ItemProperty $path -Name $val -EA 0) -ne $null) { Remove-ItemProperty $path -Name $val -Force -EA SilentlyContinue; Write-Host '    Удален твик:' $val -ForegroundColor Gray; } } } }"

echo.
echo [3/4] Принудительный перезапуск беспроводного сетевого адаптера...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$adapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*AX200*' -or $_.InterfaceDescription -like '*Wi-Fi*' -or $_.InterfaceDescription -like '*Wireless*' -or $_.Name -like '*Wi-Fi*' -or $_.Name -like '*Беспровод*' }; if ($adapter) { Write-Host '  Перезапуск адаптера:' $adapter.Name '...' -ForegroundColor Cyan; try { Disable-NetAdapter -InputObject $adapter -Confirm:$false -EA Stop; Start-Sleep -Seconds 3; Enable-NetAdapter -InputObject $adapter -Confirm:$false -EA Stop; Start-Sleep -Seconds 3; Write-Host '  Адаптер успешно перезапущен!' -ForegroundColor Green; } catch { Write-Host '  Не удалось перезапустить адаптер автоматически. Потребуется перезагрузка ПК.' -ForegroundColor Red; } } else { Write-Host '  Сетевой адаптер Wi-Fi не обнаружен.' -ForegroundColor Red; }"

echo.
echo [4/4] Сброс сетевого стека Windows (очистка кэша)...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1

echo.
echo ===========================================================
echo           ВОССТАНОВЛЕНИЕ УСПЕШНО ЗАВЕРШЕНО!
echo ===========================================================
echo.
echo Рекомендуется перезагрузить компьютер для полного применения
echo всех изменений и гарантированного восстановления отображения Wi-Fi.
echo.
echo Если вы также отключали уведомления и хотите их вернуть:
echo Запустите Start.bat, перейдите в 1. Базовые настройки,
echo выберите 7. Глобальное отключение всех уведомлений и введите 0.
echo.
echo Нажмите любую клавишу для выхода...
pause >nul
exit
