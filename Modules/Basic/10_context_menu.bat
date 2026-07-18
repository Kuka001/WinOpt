@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%Возврат классического контекстного меню Win11...%X%
set "_err=0"
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1 || set "_err=1"
call "..\..\Core\helpers.bat" apply_and_restart
exit /b