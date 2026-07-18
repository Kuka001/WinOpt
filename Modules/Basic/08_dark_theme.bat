@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%Включение тёмной темы...%X%
set "_err=0"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f >nul 2>&1 || set "_err=1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f >nul 2>&1 || set "_err=1"
reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "UI Theme" /t REG_DWORD /d 4 /f >nul 2>&1
call "..\..\Core\helpers.bat" apply_and_restart
exit /b