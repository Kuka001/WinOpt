@echo off
:: Переход к нужной функции по переданному аргументу
goto %~1

:restart_explorer
taskkill /F /IM explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe
exit /b

:show_ok
echo %G%Успешно выполнено!%X%
exit /b

:show_fail
echo %R%Ошибка при выполнении.%X%
exit /b

:apply_and_restart
if "%_err%"=="1" (
    echo %R%Ошибка при выполнении.%X%
) else (
    taskkill /F /IM explorer.exe >nul 2>&1
    timeout /t 1 /nobreak >nul
    start explorer.exe
    echo %G%Успешно выполнено!%X%
)
set "_err="
echo. & pause
exit /b