@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:uac_menu
cls
echo %Y%=== Настройка UAC ===%X%
echo.
echo 1. Полное отключение UAC (%R%ВНИМАНИЕ: Ломает Store/UWP/VPN!%X%)
echo 2. Тихий режим — без промптов (%G%Безопасно, рекомендуется%X%)
echo 0. Вернуть UAC по умолчанию
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    cls & echo Полное отключение UAC ^(EnableLUA=0^)...
    echo.
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >nul 2>&1
    
    :: Отключение предупреждений при открытии файлов (SaveZoneInformation, LowRiskFileTypes и запуск опасных файлов)
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.msi;.vbs;.js;.lnk;.zip;.rar;.tar;.gz;.7z;.reg;.ps1" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.msi;.vbs;.js;.lnk;.zip;.rar;.tar;.gz;.7z;.reg;.ps1" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 0 /f >nul 2>&1

    if !errorlevel! equ 0 (
        echo %G%Готово!%X%
        echo %R%Требуется перезагрузка. UWP-приложения могут не работать!%X%
    ) else (call "%~dp0..\..\Core\helpers.bat" show_fail)
    echo. & pause & goto uac_menu
)
if "%c%"=="2" (
    cls & echo Тихий режим UAC ^(без промптов, без затемнения^)...
    echo.
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableInstallerDetection /t REG_DWORD /d 0 /f >nul 2>&1
    
    :: Отключение предупреждений при открытии файлов (SaveZoneInformation, LowRiskFileTypes и запуск опасных файлов)
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.msi;.vbs;.js;.lnk;.zip;.rar;.tar;.gz;.7z;.reg;.ps1" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.msi;.vbs;.js;.lnk;.zip;.rar;.tar;.gz;.7z;.reg;.ps1" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 0 /f >nul 2>&1

    if !errorlevel! equ 0 (call "%~dp0..\..\Core\helpers.bat" show_ok) else (call "%~dp0..\..\Core\helpers.bat" show_fail)
    echo. & pause & goto uac_menu
)
if "%c%"=="0" (
    cls & echo Возврат UAC к значениям по умолчанию...
    echo.
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableInstallerDetection /t REG_DWORD /d 1 /f >nul 2>&1
    
    :: Возврат предупреждений при открытии файлов к значениям по умолчанию
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /t REG_DWORD /d 1 /f >nul 2>&1

    if !errorlevel! equ 0 (
        echo %G%UAC полностью восстановлен.%X%
        echo %R%Перезагрузите ПК.%X%
    ) else (call "%~dp0..\..\Core\helpers.bat" show_fail)
    echo. & pause & goto uac_menu
)
goto uac_menu