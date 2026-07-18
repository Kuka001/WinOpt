@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

:mouse_settings
cls
echo %Y%=== Настройка мыши (1:1 без ускорения) ===%X%
echo.
echo 1. Применить (6/11, без ускорения)
echo 0. Вернуть по умолчанию
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" exit /b
if "%c%"=="1" (
    :: Отключаем акселерацию (Thresholds и Speed на 0) и ставим чувствительность 10 (соответствует 6/11)
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Win32 { [DllImport(\"user32.dll\")] public static extern int SystemParametersInfo(int u, int uP, int[] lpv, int f); [DllImport(\"user32.dll\")] public static extern int SystemParametersInfo(int u, int uP, IntPtr lpv, int f); }'; [Win32]::SystemParametersInfo(0x0004, 0, [int[]](0, 0, 0), 3) | Out-Null; [Win32]::SystemParametersInfo(0x0071, 0, [IntPtr]10, 3) | Out-Null" >nul 2>&1
    
    echo %G%Мышь настроена 1:1! Изменения применены мгновенно.%X% & echo. & pause & goto mouse_settings
)
if "%c%"=="0" (
    :: Возвращаем стандартную акселерацию Windows (6, 10, 1) и стандартную скорость 10 (6/11)
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Win32 { [DllImport(\"user32.dll\")] public static extern int SystemParametersInfo(int u, int uP, int[] lpv, int f); [DllImport(\"user32.dll\")] public static extern int SystemParametersInfo(int u, int uP, IntPtr lpv, int f); }'; [Win32]::SystemParametersInfo(0x0004, 0, [int[]](6, 10, 1), 3) | Out-Null; [Win32]::SystemParametersInfo(0x0071, 0, [IntPtr]10, 3) | Out-Null" >nul 2>&1
    
    echo %G%Параметры мыши восстановлены по умолчанию!%X% & echo. & pause & goto mouse_settings
)
goto mouse_settings