@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%=== Удаление ненужных приложений ===%X%
echo.
echo %R%ВНИМАНИЕ: Будет выполнено глубокое удаление встроенных компонентов!%X%
echo %R%Будут удалены БЕЗ ВОЗВРАТА:%X%
echo  - %Y%Все UWP-приложения%X% (включая Калькулятор, Фотографии, Paint)
echo  - %Y%Все компоненты Xbox и GameBar%X% (службы также будут отключены)
echo  - %Y%Microsoft Edge%X% (браузер полностью, но WebView2 для игр останется)
echo  - %Y%OneDrive и средства удалённого доступа (Quick Assist)%X%
echo.
echo %G%Магазин приложений (Microsoft Store) и системный Поиск будут сохранены.%X%
echo.
set "c=" & set /p c="Продолжить удаление? (Y/Enter=отмена): "
if /i "!c!" neq "Y" exit /b

cls
echo %Y%Запуск удаления...%X%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\RemoveApps.ps1"
set "_err=%errorlevel%"

echo.
if !_err! equ 0 (
    call "%~dp0..\..\Core\helpers.bat" show_ok
    echo %R%Для применения изменений требуется перезагрузка компьютера.%X%
) else (
    call "%~dp0..\..\Core\helpers.bat" show_fail
)

echo. & pause
exit /b