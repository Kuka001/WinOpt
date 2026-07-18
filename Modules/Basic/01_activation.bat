@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

cls
echo %Y%Запуск скрипта активации...%X%
echo.
powershell -NoProfile -Command "irm https://get.activated.win | iex"
echo. 
echo %G%Процесс завершен.%X% 
pause
exit /b