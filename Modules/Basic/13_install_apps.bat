@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul


:: Установка winget (если пользователь на этом настаивает)
echo Проверка наличия WinGet...
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Установка Windows Package Manager WinGet...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Service -Name ClipSVC -StartupType Manual -ErrorAction SilentlyContinue; Set-Service -Name InstallService -StartupType Manual -ErrorAction SilentlyContinue; Set-Service -Name DoSvc -StartupType Manual -ErrorAction SilentlyContinue; Start-Service -Name ClipSVC, InstallService, DoSvc -ErrorAction SilentlyContinue; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }; Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile '%TEMP%\winget.msixbundle' -ErrorAction SilentlyContinue; Add-AppxPackage -Path '%TEMP%\winget.msixbundle' -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Проверяем еще раз
    winget --version >nul 2>&1
    if !errorLevel! == 0 (
        set "winget_installed_by_us=1"
    ) else (
        echo [Предупреждение] Не удалось установить WinGet. Будет использован резервный метод скачивания через curl.
        timeout /t 3 >nul
    )
)

:menu
cls
echo ==========================================================
echo                  Скачивание приложений
echo ==========================================================
echo 1. Google Chrome
echo 2. Steam
echo 3. Faceit Anti-Cheat
echo 4. 7-Zip
echo 5. KMPlayer
echo 6. Honeyview
echo 7. Cloudflare WARP (1.1.1.1)
echo 8. AIDA64 Extreme
echo 9. MSI Afterburner
echo 10. Revo Uninstaller
echo 11. NVCleanstall
echo 12. Autoruns (Sysinternals)
echo 13. NVIDIA Profile Inspector
echo.
echo A. Скачать все приложения
echo [Enter] Назад
echo ==========================================================
set "choice="
set /p choice="Выберите приложение для скачивания (1-13, A или Enter): "

:: Если просто нажат Enter
if not defined choice (
    if defined winget_installed_by_us (
        echo Удаление WinGet по запросу пользователя...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *Microsoft.DesktopAppInstaller* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
    )
    exit /b
)

if /i "%choice%"=="A" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\InstallApps.ps1" "all"
    goto menu
)

set "valid="
for /L %%i in (1,1,13) do (
    if "%choice%"=="%%i" set valid=1
)
if defined valid (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\InstallApps.ps1" "%choice%"
    goto menu
)

echo Неверный выбор!
timeout /t 2 >nul
goto menu