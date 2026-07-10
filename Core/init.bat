@echo off
:: Установка кодировки UTF-8
chcp 65001 >nul

:: Включение поддержки ANSI-цветов в консоли
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%A in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%A"

:: Объявление цветовых переменных
set "R=%ESC%[31m"
set "G=%ESC%[32m"
set "Y=%ESC%[33m"
set "X=%ESC%[0m"