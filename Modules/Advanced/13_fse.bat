@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%Настройка FSE, отключение FSO и оптимизаций оконного режима...%X%

:: 1. Исправление параметров FSE и отключение оптимизации во весь экран (глобально)
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1

:: 2. Отключение "Оптимизации для игр в оконном режиме" в Windows 11 (через замену флага)
powershell -Command "$p='HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }; $v=(Get-ItemProperty -Path $p -Name DirectXUserGlobalSettings -ErrorAction SilentlyContinue).DirectXUserGlobalSettings; if ($v) { if ($v -like '*SwapEffectUpgradeEnable=1*') { $v = $v -replace 'SwapEffectUpgradeEnable=1', 'SwapEffectUpgradeEnable=0' } elseif ($v -notlike '*SwapEffectUpgradeEnable=*') { $v = $v + 'SwapEffectUpgradeEnable=0;' } } else { $v = 'SwapEffectUpgradeEnable=0;' }; Set-ItemProperty -Path $p -Name DirectXUserGlobalSettings -Value $v -Type String" >nul 2>&1

:: 3. Дополнительно: Отключение Game DVR и Game Bar (рекомендуется)
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo %G%Настройки успешно применены!%X%
echo. & pause
exit /b