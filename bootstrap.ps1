# Установка кодировки консоли в UTF-8 для корректного отображения кириллицы
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Блок проверки прав Администратора. 
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $bootstrapUrl = "https://raw.githubusercontent.com/Kuka001/WinOpt/main/bootstrap.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb '$bootstrapUrl' | iex`"" -Verb RunAs
    exit
}

$repoUrl = "https://github.com/Kuka001/WinOpt/archive/refs/heads/main.zip"
$tempDir = Join-Path $env:TEMP "WinOptToolkit"
$zipFile = Join-Path $env:TEMP "toolkit.zip"

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $zipFile) { Remove-Item $zipFile -Force -ErrorAction SilentlyContinue }

Write-Host "Скачивание файлов оптимизатора..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri $repoUrl -OutFile $zipFile
} catch {
    Write-Error "Не удалось скачать архив."
    pause; exit
}

Write-Host "Распаковка..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
} catch {
    Write-Error "Ошибка при распаковке."
    pause; exit
}

$extractedFolder = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1

if ($extractedFolder) {
    Write-Host "Нормализация окончаний строк (LF -> CRLF)..." -ForegroundColor Yellow
    
    # Критически важно: cmd.exe ломается на LF-окончаниях строк.
    # Преобразуем все .bat файлы в CRLF и сохраняем строго в UTF-8 без BOM.
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    Get-ChildItem -Path $extractedFolder.FullName -Recurse -Filter *.bat | ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        $normalized = $content -replace "\r?\n", "`r`n"
        [System.IO.File]::WriteAllText($_.FullName, $normalized, $utf8NoBom)
    }

    $startBat = Join-Path $extractedFolder.FullName "Start.bat"
    if (Test-Path $startBat) {
        Write-Host "Запуск..." -ForegroundColor Green
        Set-Location $extractedFolder.FullName
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c Start.bat" -Wait
    } else {
        Write-Warning "Файл Start.bat не найден."
        pause
    }
} else {
    Write-Warning "Ошибка структуры архива."
    pause
}