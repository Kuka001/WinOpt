@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Kazuma Optimizer

cd /d "%~dp0"

:: Надежная проверка на права Администратора (не зависит от отключенных служб)
fsutil dirty query %systemdrive% >nul 2>&1
if %errorLevel% equ 0 goto :skip_admin
echo Запрос прав Администратора...
set "MY_DP0=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList ('/k cd /d ' + [char]34 + $env:MY_DP0 + [char]34 + ' && Start.bat') -Verb RunAs"
exit /b
:skip_admin

:: Подгружаем ядро
pushd "%~dp0Core"
call init.bat
popd

:: ==========================================
:main_menu
cls
echo %G%*** ПАК оптимизации Windows от Kazuma ***%X%
echo.
echo 1. Базовые настройки
echo 2. Полная оптимизация
echo.
set "c=" & set /p c="Выбор (Enter=выход): "
if "%c%"=="" exit /b
if "%c%"=="1" goto basic_settings
if "%c%"=="2" goto full_optimization
goto main_menu

:: ==========================================
:basic_settings
cls
echo %Y%=== Базовые настройки ===%X%
echo.
echo  1. Активация Windows/Office
echo  2. Настройка UAC
echo  3. Настройка BitLocker
echo  4. Автонастройка времени
echo  5. Настройка языков/раскладка клавиатуры
echo  6. Включить журнал буфера обмена (Win+V)
echo  7. Глобальное отключение всех уведомлений
echo  8. Включить темную тему
echo  9. Отображение скрытых файлов и расширений
echo 10. Классическое контекстное меню Win11
echo 11. Настройка панели задач
echo 12. Настройка проводника
echo 13. Скачивание приложений
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" goto main_menu
if "%c%"=="1" call "Modules\Basic\01_activation.bat"
if "%c%"=="2" call "Modules\Basic\02_uac.bat"
if "%c%"=="3" call "Modules\Basic\03_bitlocker.bat"
if "%c%"=="4" call "Modules\Basic\04_time_sync.bat"
if "%c%"=="5" call "Modules\Basic\05_language.bat"
if "%c%"=="6" call "Modules\Basic\06_clipboard.bat"
if "%c%"=="7" call "Modules\Basic\07_notifications.bat"
if "%c%"=="8" call "Modules\Basic\08_dark_theme.bat"
if "%c%"=="9" call "Modules\Basic\09_hidden_files.bat"
if "%c%"=="10" call "Modules\Basic\10_context_menu.bat"
if "%c%"=="11" call "Modules\Basic\11_taskbar.bat"
if "%c%"=="12" call "Modules\Basic\12_explorer.bat"
if "%c%"=="13" call "Modules\Basic\13_install_apps.bat"
goto basic_settings

:: ==========================================
:full_optimization
cls
echo %Y%=== Полная оптимизация ===%X%
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" >nul 2>&1
if %errorlevel% neq 0 (
    set "SM_STATUS= %R%[Требуется Безопасный режим]%X%"
) else (
    set "SM_STATUS= %G%[Безопасный режим]%X%"
)
echo  1. Отключение/включение безопасности Windows%SM_STATUS%
echo  2. Отключение/включение обновлений Windows%SM_STATUS%
echo  3. Отключение телеметрии
echo  4. Отключение рекомендаций и рекламы
echo  5. Отключение ненужных служб
echo  6. Удаление ненужных приложений
echo  7. Настройка электропитания
echo  8. Отключение GameBar и Игровой режим/Включение HAGS
echo  9. Оптимизация сети
echo 10. Отключение энергосбережения устройств
echo 11. Настройка прерываний таймера
echo 12. Настройка MMCSS
echo 13. Настройка FSE
echo 14. Win32PrioritySeparation
echo 15. Быстродействие Windows
echo 16. Настройка VBS (для Faceit)
echo 17. Оптимизация памяти и NTFS
echo 18. Настройка мыши (1:1 без ускорения)
echo 19. Отключение Spectre/Meltdown митигаций
echo 20. Настройка файла подкачки (Pagefile)
echo 21. Установка профиля NVIDIA (настройки драйвера)
echo 22. Affinity и MSI Mode (Device Tweaker)
echo 23. Настройка Steam
echo.
set "c=" & set /p c="Выбор (Enter=назад): "
if "%c%"=="" goto main_menu
if "%c%"=="1" call "Modules\Advanced\01_defender.bat"
if "%c%"=="2" call "Modules\Advanced\02_windows_update.bat"
if "%c%"=="3" call "Modules\Advanced\03_telemetry.bat"
if "%c%"=="4" call "Modules\Advanced\04_recommendations.bat"
if "%c%"=="5" call "Modules\Advanced\05_services.bat"
if "%c%"=="6" call "Modules\Advanced\06_remove_apps.bat"
if "%c%"=="7" call "Modules\Advanced\07_power_plan.bat"
if "%c%"=="8" call "Modules\Advanced\08_gamebar_hags.bat"
if "%c%"=="9" call "Modules\Advanced\09_network.bat"
if "%c%"=="10" call "Modules\Advanced\10_powersaving.bat"
if "%c%"=="11" call "Modules\Advanced\11_timer.bat"
if "%c%"=="12" call "Modules\Advanced\12_mmcss.bat"
if "%c%"=="13" call "Modules\Advanced\13_fse.bat"
if "%c%"=="14" call "Modules\Advanced\14_win32priority.bat"
if "%c%"=="15" call "Modules\Advanced\15_performance.bat"
if "%c%"=="16" call "Modules\Advanced\16_vbs.bat"
if "%c%"=="17" call "Modules\Advanced\17_memory_ntfs.bat"
if "%c%"=="18" call "Modules\Advanced\18_mouse.bat"
if "%c%"=="19" call "Modules\Advanced\19_spectre.bat"
if "%c%"=="20" call "Modules\Advanced\21_pagefile.bat"
if "%c%"=="21" call "Modules\Advanced\22_nvidia_profile.bat"
if "%c%"=="22" call "Modules\Advanced\23_affinity_msi.bat"
if "%c%"=="23" call "Modules\Advanced\24_steam.bat"
goto full_optimization