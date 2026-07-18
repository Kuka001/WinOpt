@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:spectre_mitigations
cls
echo %Y%=== Отключение Spectre/Meltdown/Downfall митигаций ===%X%
echo.
echo 1. Отключить митигации (максимум FPS, включая Downfall)
echo 0. Включить митигации (по умолчанию)
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b

if "%c%"=="1" (
    :: 33554435 (0x2000003) отключает Spectre/Meltdown (3) + Downfall (33554432)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 33554435 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo %G%Отключено! Изменения вступят в силу после перезагрузки.%X%
    ) else (
        echo %R%Не удалось применить изменения реестра!%X%
    )
    echo. & pause & goto spectre_mitigations
)

if "%c%"=="0" (
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /f >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /f >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo %G%Восстановлено! Изменения вступят в силу после перезагрузки.%X%
    ) else (
        echo %R%Не удалось удалить ключи из реестра!%X%
    )
    echo. & pause & goto spectre_mitigations
)

goto spectre_mitigations