# Установка кодировки консоли в UTF-8 для корректного отображения кириллицы
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoUrl = "https://github.com/Kuka001/WinOpt/archive/refs/heads/main.zip"

# Определяем путь к Рабочему столу
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Алгоритм автоматического вычисления следующей версии папки
$highest = 0

# Ищем папки, подходящие под шаблон названия на Рабочем столе
$folders = Get-ChildItem -Path $desktopPath -Directory -Filter "Kazuma_Optimizer_Git_version(*)"
foreach ($folder in $folders) {
    # Регулярным выражением извлекаем число из круглых скобок
    if ($folder.Name -match 'Kazuma_Optimizer_Git_version\((\d+)\)') {
        $num = [int]$Matches[1]
        if ($num -gt $highest) {
            $highest = $num
        }
    }
}

# Номер новой версии папки (если папок нет, $highest равен 0, поэтому новая папка получит номер 1)
$nextNum = $highest + 1
$folderName = "Kazuma_Optimizer_Git_version($nextNum)"
$finalFolder = Join-Path $desktopPath $folderName

$tempDir = Join-Path $env:TEMP "WinOptToolkit"
$zipFile = Join-Path $env:TEMP "toolkit.zip"

# Очистка временных файлов в системной папке TEMP (не влияет на файлы на Рабочем столе)
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
    
    # Побайтовое исправление строк во всех .bat файлах перед переносом на Рабочий стол
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

    # Переносим распакованный проект на Рабочий стол с новым именем (конфликт исключен)
    Move-Item -Path $extractedFolder.FullName -Destination $finalFolder -Force

    Write-Host "Проект успешно сохранен на Рабочий стол!" -ForegroundColor Green
    Write-Host "Создана новая папка: $folderName" -ForegroundColor Green
    
    # Автоматически открываем созданную папку в Проводнике
    Start-Process explorer.exe -ArgumentList "`"$finalFolder`""
} else {
    Write-Warning "Ошибка структуры архива."
    pause
}