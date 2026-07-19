@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:module_menu
cls
echo %Y%==========================================================%X%
echo                  Скачивание приложений
echo %Y%==========================================================%X%
echo %G%1.%X% Google Chrome
echo %G%2.%X% Steam
echo %G%3.%X% Faceit Anti-Cheat
echo %G%4.%X% 7-Zip
echo %G%5.%X% KMPlayer
echo %G%6.%X% Honeyview
echo %G%7.%X% Cloudflare WARP (1.1.1.1)
echo %G%8.%X% AIDA64 Extreme
echo %G%9.%X% MSI Afterburner
echo %G%10.%X% Revo Uninstaller
echo %G%11.%X% NVCleanstall
echo %G%12.%X% Autoruns (Sysinternals)
echo %G%13.%X% NVIDIA Profile Inspector
echo %G%14.%X% Visual C++ Redistributable AIO (abbodi1406)
echo.
echo %G%A.%X% Скачать все приложения
echo %R%[Enter] Назад%X%
echo %Y%==========================================================%X%
set "choice="
set /p choice="Выберите приложение для скачивания (1-14, A или Enter): "

if not defined choice exit /b

if /i "%choice%"=="A" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\InstallApps.ps1" "all"
    pause
    goto module_menu
)

set "valid="
for /L %%i in (1,1,14) do (
    if "%choice%"=="%%i" set valid=1
)
if defined valid (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\InstallApps.ps1" "%choice%"
    pause
    goto module_menu
)

call "%~dp0..\..\Core\helpers.bat" show_fail "Неверный выбор!"
timeout /t 2 >nul
goto module_menu