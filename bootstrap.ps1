# Блок проверки прав Администратора. 
# Если запущено без прав админа, скрипт перезапустит себя с повышением прав.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Здесь используется прямая ссылка на этот же скрипт, чтобы перезапуститься от имени Администратора
    $bootstrapUrl = "https://raw.githubusercontent.com/Kuka001/WinOpt/main/bootstrap.ps1"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb '$bootstrapUrl' | iex`"" -Verb RunAs
    exit
}

# Ссылки для скачивания (замените ВАШ_НИКНЕЙМ и ИМЯ_РЕПОЗИТОРИЯ на свои данные)
$repoUrl = "https://github.com/Kuka001/WinOpt/archive/refs/heads/main.zip"
$tempDir = Join-Path $env:TEMP "WinOptToolkit"
$zipFile = Join-Path $env:TEMP "toolkit.zip"

# Очистка предыдущих запусков, если они остались
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $zipFile) { Remove-Item $zipFile -Force -ErrorAction SilentlyContinue }

Write-Host "Скачивание файлов оптимизатора..." -ForegroundColor Yellow
try {
    # Скачивание архива репозитория
    Invoke-RestMethod -Uri $repoUrl -OutFile $zipFile
} catch {
    Write-Error "Не удалось скачать архив. Проверьте подключение к сети."
    pause
    exit
}

Write-Host "Распаковка..." -ForegroundColor Yellow
try {
    # Распаковка во временную директорию пользователя
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
} catch {
    Write-Error "Ошибка при распаковке файлов."
    pause
    exit
}

# GitHub упаковывает репозиторий в подпапку вида "ИМЯ_РЕПОЗИТОРИЯ-main". Находим её:
$extractedFolder = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1

if ($extractedFolder) {
    $startBat = Join-Path $extractedFolder.FullName "Start.bat"
    if (Test-Path $startBat) {
        Write-Host "Запуск..." -ForegroundColor Green
        # Переходим в рабочую директорию распакованного проекта
        Set-Location $extractedFolder.FullName
        # Запускаем основной cmd-скрипт и ждем его завершения
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c Start.bat" -NoNewWindow -Wait
    } else {
        Write-Warning "Файл Start.bat не найден внутри архива."
        pause
    }
} else {
    Write-Warning "Не удалось найти распакованную папку проекта."
    pause
}

# Необязательная очистка после закрытия оптимизатора
# Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
# Remove-Item $zipFile -Force -ErrorAction SilentlyContinue