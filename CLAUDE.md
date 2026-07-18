# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Windows optimization toolkit ("ПАК оптимизации Windows от Kazuma") — a modular system of batch scripts and PowerShell scripts for deep Windows 10/11 system tweaks, primarily targeting gaming performance (CS2, Faceit anti-cheat compatibility).

**All user-facing text is in Russian.** Maintain Russian for all menu text, messages, and comments.

## Running

No build step. Run `Start.bat` as Administrator (it self-elevates via PowerShell if needed). Some modules (Defender, Windows Update) require Safe Mode.

## Architecture

```
Start.bat                    Entry point, main menu
Core/
  init.bat                   Bootstrap: UTF-8 (cp65001), ANSI colors, color vars (R/G/Y/X)
  helpers.bat                Shared functions called via: call helpers.bat <function_name>
Modules/
  Basic/01-13_*.bat          User-facing Windows settings (registry tweaks)
  Advanced/01-23_*.bat       Performance/security tweaks (menus that delegate to Scripts/)
Scripts/
  *.ps1                      PowerShell scripts for operations requiring elevated privileges
```

**Control flow:** `Start.bat` → loads `Core/init.bat` → shows menu → calls `Modules/.../*.bat` → modules call `Scripts/*.ps1` for complex operations.

## Conventions

### Batch modules pattern
Every `.bat` module follows this structure:
```batch
@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

:module_menu
cls
echo %Y%=== Title ===%X%
echo.
:: menu items with color-coded warnings: %R% for danger, %G% for safe/recommended
set "c=" & set /p c="Выбор (Enter=назад): "
:: handle choices, call helpers for feedback
echo. & pause & goto module_menu
```

### Color variables (from init.bat)
- `%R%` — red (warnings, dangerous options)
- `%G%` — green (success, safe/recommended options)
- `%Y%` — yellow (section headers, informational)
- `%X%` — reset

### Helper functions (Core/helpers.bat)
Called via `call "%~dp0..\..\Core\helpers.bat" <function>`:
- `show_ok` — green success message
- `show_fail` — red error message
- `restart_explorer` — kills and restarts explorer.exe
- `apply_and_restart` — checks `%_err%` var, restarts explorer if success

### PowerShell scripts
- Always invoked with `-NoProfile -ExecutionPolicy Bypass -File`
- Accept mode arguments (e.g., `DISABLE`/`ENABLE`)
- Use P/Invoke for TrustedInstaller impersonation when modifying protected registry keys
- Self-contained — each script includes all necessary Win32 API declarations

### Line endings & File Encoding (CRITICAL)
- **All `.bat` files MUST use CRLF (`\r\n`).** Windows `cmd.exe` не может корректно парсить batch-файлы с LF-окончаниями — скрипт молча падает/закрывается на этапе чтения структуры кода. При создании или редактировании всегда проверяй, что используется CRLF.
- **Кодировка .bat файлов:** Скрипты должны сохраняться строго в **UTF-8 без BOM** (UTF-8 without BOM) либо в **ANSI (Windows-1251)**. Использование кодировки UTF-8 с BOM (Byte Order Mark) приводит к тому, что в начало файла записывается невидимая сигнатура, из-за которой `cmd.exe` падает с ошибкой `"я╗┐@echo" не является внутренней или внешней командой`.
- Если `.bat` файл генерируется программно (например, через PowerShell), заменяй `\n` → `\r\n` и записывай без BOM: `[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)`.
- `.ps1` файлы могут быть как CRLF так и LF, а также с BOM или без него — PowerShell корректно обрабатывает все варианты.

### Syntactic Pitfalls / Ограничения синтаксиса (CRITICAL)
- **Никаких комментариев `::` внутри круглых скобок `()`!** Использование комментариев, начинающихся с двоеточия `::`, внутри многострочных конструкций `for (...)` или `if (...)` приводит к критическому сбою парсинга `cmd.exe` (интерпретатор ошибочно считает их невалидными метками переходов). Скрипт в этом случае мгновенно аварийно закрывается без явных логов.
- **Комментарии внутри списков `for`:** Внутри круглых скобок цикла `for %%V in (...)` нельзя использовать даже стандартные `rem`-комментарии, так как парсер воспримет слово `rem` как очередной элемент для итерации цикла. Списки элементов внутри круглых скобок всегда должны быть чистыми от любых комментариев. Пишите все пояснения до или после цикла.
- **Проблема путей со скобками при повышении прав (Windows 11 / Windows Terminal):**
  - **Описание бага:** Если путь к папке скрипта содержит круглые скобки (например, `Kazuma_Optimizer_Git_version(4)`), запуск от имени Администратора через PowerShell `Start-Process cmd.exe -ArgumentList '/k Start.bat'` аварийно вылетает с ошибкой `"C:\Users\...\Kazuma_Optimizer_Git_version" не является внутренней или внешней командой...`. Это происходит потому, что `cmd.exe` принудительно срезает внешние кавычки, если команда начинается с кавычки и содержит круглые скобки (которые CMD считает специальными символами). Кроме того, Windows Terminal сбрасывает рабочую директорию повышенного процесса до `C:\Windows\System32`, ломая относительные пути.
  - **Правильное решение:** Для запроса прав Администратора ВСЕГДА используйте передачу пути через переменную окружения `$env:MY_DP0` без кавычек на стороне CLI, а в качестве команды передавайте `cd /d "путь" && Start.bat`. Поскольку команда начинается со слова `cd`, CMD **никогда не срезает кавычки**, путь со скобками успешно обрабатывается, а переход в рабочую папку работает безотказно:
    ```batch
    set "MY_DP0=%~dp0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList ('/k cd /d ' + [char]34 + $env:MY_DP0 + [char]34 + ' && Start.bat') -Verb RunAs"
    ```

### Registry operations
- Batch modules handle simple `reg add`/`reg delete` operations directly
- Suppress output with `>nul 2>&1`
- Check `!errorlevel!` for success/failure feedback
- PowerShell scripts handle protected keys that require TrustedInstaller token

## Key Technical Details

- Admin check uses `fsutil dirty query %systemdrive%` (works even with disabled services, unlike `net session`)
- ANSI escape sequences obtained via PowerShell: `for /f %%A in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%A"`
- PowerShell scripts use DACL manipulation to lock services and prevent Windows from re-enabling them
- `Defender.ps1` contains a full in-memory .reg file parser (no temp file writes)
- Services backup/restore uses CSV format at `%USERPROFILE%\Desktop\services_backup.csv`