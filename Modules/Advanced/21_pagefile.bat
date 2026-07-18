@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

:pagefile_setup
cls
echo %Y%=== Фиксация файла подкачки (Pagefile) ===%X%
echo.
echo 1. Установить фикс. размер 8192 МБ ^(8 ГБ^)
echo 2. Установить фикс. размер 16384 МБ ^(16 ГБ^)
echo 3. Отключить полностью
echo 0. Вернуть автоматический режим
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="0" set "PF_ARG=Auto" & goto run_pagefile
if "%c%"=="1" set "PF_ARG=8192" & goto run_pagefile
if "%c%"=="2" set "PF_ARG=16384" & goto run_pagefile
if "%c%"=="3" set "PF_ARG=None" & goto run_pagefile
goto pagefile_setup

:run_pagefile
cls
echo %Y%Настройка файла подкачки...%X%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\Pagefile.ps1" "%PF_ARG%"
echo.
echo %G%Операция завершена!%X%
echo %Y%Внимание: Изменения вступят в силу только после перезагрузки компьютера.%X%
echo. & pause
exit /b