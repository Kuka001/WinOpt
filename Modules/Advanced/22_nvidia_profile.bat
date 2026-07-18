@echo off
setlocal EnableDelayedExpansion
call "..\..\Core\init.bat"

for %%i in ("%~dp0..\..") do set "ROOT_DIR=%%~fi"
set "NPI_PATH=%ROOT_DIR%\MyProgramsEXE\NvidiaProfileInspector\nvidiaProfileInspector.exe"

cls
echo %Y%=== Установка профиля NVIDIA Profile Inspector ===%X%
echo.

if not exist "%NPI_PATH%" (
    echo %R%[ОШИБКА] Nvidia Profile Inspector не найден!%X%
    echo %R%Ожидаемый путь: %NPI_PATH%%X%
    echo.
    echo %Y%Убедитесь, что в папке оптимизатора есть папка MyProgramsEXE\NvidiaProfileInspector%X%
    echo %Y%с программой nvidiaProfileInspector.exe внутри.%X%
    echo. & pause
    exit /b
)

echo %Y%Применение оптимизированного профиля NVIDIA...%X%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\Scripts\nvidia_profile.ps1" -NpiPath "%NPI_PATH%"

if !errorlevel! equ 0 (
    echo.
    echo %G%[ОК] Профиль NVIDIA успешно применён!%X%
    echo.
    echo %Y%Применённые настройки:%X%
    echo  - Power management: Prefer Maximum Performance
    echo  - Texture filtering: High Performance
    echo  - Pre-rendered frames: 1
    echo  - Threaded optimization: On
    echo  - Vertical Sync: Off
    echo  - HAGS/rBAR: Enabled
    echo  - Low Latency Mode: On
    echo  - Shader Cache: Unlimited
    echo  - Ansel: Disabled
    echo  - FXAA: Disabled
) else (
    echo.
    echo %R%[ОШИБКА] Не удалось применить профиль. Код ошибки: !errorlevel!%X%
    echo %Y%Попробуйте запустить вручную через Nvidia Profile Inspector.%X%
)

echo. & pause
exit /b
