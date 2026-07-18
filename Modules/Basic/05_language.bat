@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

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
    powershell -NoProfile -Command "$L=Get-WinUserLanguageList; $R=$L.Where({$_.LanguageTag -match '^ru'}); if($R){$R=$R[0]}; $layoutExists=$R -and $R.InputMethodTips.Contains('0419:0000043F'); $hotkeyExists=(Get-ItemProperty -Path 'HKCU:\Keyboard Layout\Toggle' -ErrorAction SilentlyContinue).'Layout Hotkey' -eq '2'; if($layoutExists){ Write-Host '%Y%Русская + Казахская раскладка уже существует внутри Русского языка.%X%'; if(-not $hotkeyExists){ Write-Host '%G%Переключение раскладки (Ctrl+Shift) успешно настроено.%X%' }; Write-Host '%G%Для смены раскладки используйте: Ctrl+Shift%X%' } else { $L=@($L.Where({$_.LanguageTag -notmatch '^kk'})); if(-not $R){ $R=(New-WinUserLanguageList 'ru-RU')[0]; $L+=$R; $s='успешно создана с нуля.' } else { $s='успешно добавлена в Русскую раскладку.' }; if(-not $R.InputMethodTips.Contains('0419:00000419')) { $R.InputMethodTips.Add('0419:00000419') }; if(-not $R.InputMethodTips.Contains('0419:0000043F')) { $R.InputMethodTips.Add('0419:0000043F') }; Set-WinUserLanguageList $L -Force; Write-Host ('%G%Русская + Казахская раскладка ' + $s + '%X%'); if(-not $hotkeyExists){ Write-Host '%G%Переключение раскладки (Ctrl+Shift) успешно настроено.%X%' }; Write-Host '%G%Для смены раскладки используйте: Ctrl+Shift%X%' }"
    reg add "HKCU\Keyboard Layout\Toggle" /v "Language Hotkey" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "HKCU\Keyboard Layout\Toggle" /v "Layout Hotkey" /t REG_SZ /d "2" /f >nul 2>&1
    echo. & pause & goto language_menu
)
goto language_menu