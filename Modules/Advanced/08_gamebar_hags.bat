@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%=== Настройка GameBar, Игрового режима и HAGS ===%X%
echo.
echo %Y%Применение настроек:%X%
echo 1. Отключение GameBar и GameDVR...
echo 2. Отключение Игрового режима (Game Mode)...
echo 3. Включение HAGS (Планирование графического процессора)...
echo.

:: Применение параметров в реестре
:: HwSchMode = 2 (Включить HAGS)
:: AutoGameModeEnabled / AllowAutoGameMode = 0 (Отключить Игровой режим)
for %%V in (
    "HKCU\System\GameConfigStore,GameDVR_Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR,AppCaptureEnabled,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR,AllowGameDVR,0"
    "HKCU\Software\Microsoft\GameBar,UseNexusForGameBarEnabled,0"
    "HKCU\Software\Microsoft\GameBar,AutoGameModeEnabled,0"
    "HKCU\Software\Microsoft\GameBar,AllowAutoGameMode,0"
    "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers,HwSchMode,2"
) do (for /f "tokens=1,2,3 delims=," %%a in (%%V) do reg add "%%a" /v "%%b" /t REG_DWORD /d %%c /f >nul 2>&1)

:: Принудительное завершение фоновых процессов GameBar
taskkill /F /IM bcastdvr.exe >nul 2>&1
taskkill /F /IM GameBar.exe >nul 2>&1

:: Полное удаление Xbox Gaming Overlay для всех пользователей системы
powershell -NoProfile -Command "Get-AppxPackage *XboxGamingOverlay* -AllUsers|Remove-AppxPackage -AllUsers -EA 0" >nul 2>&1

echo.
echo %G%[ОК] Настройки успешно применены:%X%
echo %R%[-] GameBar полностью отключен и удален.%X%
echo %R%[-] Игровой режим (Game Mode) отключен.%X%
echo %G%[+] HAGS (Планирование GPU) включен.%X%
echo.
echo %Y%Для вступления всех изменений в силу обязательно перезагрузите ПК.%X%
echo. & pause
exit /b