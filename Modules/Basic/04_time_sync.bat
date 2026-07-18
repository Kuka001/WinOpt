@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%Настройка времени (UTC+05:00 Кызылорда)...%X%
echo.
tzutil /s "Qyzylorda Standard Time" >nul 2>&1
tzutil /s "Kyzylorda Standard Time" >nul 2>&1
sc config w32time start= demand >nul 2>&1
net start w32time >nul 2>&1
w32tm /resync >nul 2>&1
echo %G%Часовой пояс установлен, время синхронизировано.%X%
echo. & pause
exit /b