@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:language_menu
cls
echo %Y%=== Настройка языков ===%X%
echo.
echo 1. Добавить русскую раскладку
echo 2. Добавить казахскую раскладку
echo 3. Русская + Казахская (Ctrl+Shift)
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    cls & echo Добавление русского языка...
    powershell -NoProfile -Command "$L=Get-WinUserLanguageList; if(-not($L|?{$_.LanguageTag-match'^ru'})){$L.Add((New-WinUserLanguageList 'ru-RU')[0]);Set-WinUserLanguageList $L -Force}" >nul 2>&1
    echo %G%Русский язык добавлен.%X% & echo. & pause & goto language_menu
)
if "%c%"=="2" (
    cls & echo Добавление казахского языка...
    powershell -NoProfile -Command "$L=Get-WinUserLanguageList; if(-not($L|?{$_.LanguageTag-match'^kk'})){$L.Add((New-WinUserLanguageList 'kk-KZ')[0]);Set-WinUserLanguageList $L -Force}" >nul 2>&1
    echo %G%Казахский язык добавлен.%X% & echo. & pause & goto language_menu
)
if "%c%"=="3" (
    cls & echo Настройка комбинированной раскладки...
    powershell -NoProfile -Command "$L=Get-WinUserLanguageList;$L=@($L|?{$_.LanguageTag-notmatch'^kk'});$R=$L|?{$_.LanguageTag-match'^ru'};if(-not $R){$R=(New-WinUserLanguageList 'ru-RU')[0];$L+=$R};if(-not $R.InputMethodTips.Contains('0419:0000043F')){$R.InputMethodTips.Add('0419:0000043F')};Set-WinUserLanguageList $L -Force" >nul 2>&1
    reg add "HKCU\Keyboard Layout\Toggle" /v "Language Hotkey" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "HKCU\Keyboard Layout\Toggle" /v "Layout Hotkey" /t REG_SZ /d "2" /f >nul 2>&1
    echo %G%Готово!%X% & echo. & pause & goto language_menu
)
goto language_menu