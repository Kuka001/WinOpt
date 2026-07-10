# Установка кодировки консоли в UTF-8 для корректного отображения кириллицы
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoUrl = "https://github.com/Kuka001/WinOpt/archive/refs/heads/main.zip"

# Надежный способ определить путь к Рабочему столу текущего пользователя
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$finalFolder = Join-Path $desktopPath "Kazuma_Optimizer"

$tempDir = Join-Path $env:TEMP "WinOptToolkit"
$zipFile = Join-Path $env:TEMP "toolkit.zip"

# Очистка временных папок от прошлых запусков
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
    
    # Побайтовое исправление строк во всех .bat файлах перед переносом
    Get-ChildItem -Path $extractedFolder.FullName -Recurse -Filter *.bat | ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $newBytes = New-Object System.Collections.Generic.List[byte]
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 10) { # LF
                if ($i -eq 0 -or $bytes[$i-1] -ne 13) {
                    $newBytes.Add([byte]13)
                }
            }
            $newBytes.Add($bytes[$i])
        }
        [System.IO.File]::WriteAllBytes($_.FullName, $newBytes.ToArray())
    }

    # Если папка уже существует на Рабочем столе, удаляем старую версию перед заменой
    if (Test-Path $finalFolder) {
        Remove-Item $finalFolder -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Переносим распакованный проект на Рабочий стол и переименовываем в Kazuma_Optimizer
    Move-Item -Path $extractedFolder.FullName -Destination $finalFolder -Force

    Write-Host "Проект успешно сохранен на Рабочий стол!" -ForegroundColor Green
    Write-Host "Путь к папке: $finalFolder" -ForegroundColor Green
    Write-Host "Теперь вы можете запускать его вручную через файл Start.bat." -ForegroundColor Green
    
    # Автоматически открываем созданную папку в Проводнике
    Start-Process explorer.exe -ArgumentList "`"$finalFolder`""
} else {
    Write-Warning "Ошибка структуры архива."
    pause
}