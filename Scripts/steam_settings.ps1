# Установка UTF-8 для вывода в консоль
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Функция для поиска папки установки Steam
function Get-SteamPath {
    $pathsToCheck = @(
        "HKCU:\Software\Valve\Steam",
        "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam",
        "HKLM:\SOFTWARE\Valve\Steam"
    )
    foreach ($path in $pathsToCheck) {
        if (Test-Path $path) {
            $regVal = Get-ItemProperty -Path $path -Name "SteamPath" -ErrorAction SilentlyContinue
            if ($regVal -and $regVal.SteamPath) {
                $p = $regVal.SteamPath -replace '/', '\'
                if (Test-Path $p) { return $p }
            }
            $regVal2 = Get-ItemProperty -Path $path -Name "InstallPath" -ErrorAction SilentlyContinue
            if ($regVal2 -and $regVal2.InstallPath) {
                $p = $regVal2.InstallPath -replace '/', '\'
                if (Test-Path $p) { return $p }
            }
        }
    }
    # Стандартные пути
    $defaultPaths = @(
        "${env:ProgramFiles(x86)}\Steam",
        "${env:ProgramFiles}\Steam",
        "C:\Program Files (x86)\Steam",
        "C:\Program Files\Steam"
    )
    foreach ($p in $defaultPaths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$SteamPath = Get-SteamPath
if (-not $SteamPath) {
    Write-Host "[Ошибка] Не удалось автоматически найти папку установки Steam." -ForegroundColor Red
    $SteamPath = Read-Host "Пожалуйста, введите путь к папке Steam вручную (например, C:\Program Files (x86)\Steam)"
    if (-not (Test-Path $SteamPath)) {
        Write-Host "[Ошибка] Указанный путь не существует." -ForegroundColor Red
        Exit 1
    }
}

Write-Host "=== Применение настроек Steam ===" -ForegroundColor Yellow
Write-Host "Папка Steam: $SteamPath"
Write-Host ""

# Проверка запущенного Steam
$steamProcesses = Get-Process -Name "steam" -ErrorAction SilentlyContinue
if ($steamProcesses) {
    Write-Host "[Внимание] Steam сейчас запущен." -ForegroundColor Yellow
    Write-Host "Перед заменой файлов настроек необходимо закрыть Steam, чтобы он не перезаписал их при выходе."
    Write-Host "1. Закрыть Steam автоматически (рекомендуется)"
    Write-Host "2. Я закрою Steam вручную"
    $choice = Read-Host "Выберите вариант (1/2, Enter = 1)"
    if ($choice -ne "2") {
        Write-Host "Закрытие Steam..."
        Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Пожалуйста, закройте Steam вручную (Steam -> Выход)."
        Read-Host "После закрытия Steam нажмите Enter для продолжения..."
    }
}

# Папка с внедренными настройками в проекте
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$resourcesPath = Join-Path $scriptPath "..\Resources\Steam"

$embedConfig = Join-Path $resourcesPath "config\config.vdf"
$embedLocalconfig = Join-Path $resourcesPath "userdata\config\localconfig.vdf"
$embedSharedconfig = Join-Path $resourcesPath "userdata\7\remote\sharedconfig.vdf"

# 1. Восстановление config.vdf
if (Test-Path $embedConfig) {
    $destConfigDir = Join-Path $SteamPath "config"
    if (-not (Test-Path $destConfigDir)) {
        New-Item -ItemType Directory -Path $destConfigDir -Force | Out-Null
    }
    Copy-Item -Path $embedConfig -Destination (Join-Path $destConfigDir "config.vdf") -Force
    Write-Host "[+] Успешно применен глобальный config.vdf" -ForegroundColor Green
} else {
    Write-Host "[Ошибка] Встроенный config.vdf не найден в ресурсах проекта." -ForegroundColor Red
}

# 2. Восстановление настроек для всех аккаунтов в userdata
$targetUserdataPath = Join-Path $SteamPath "userdata"
if (Test-Path $targetUserdataPath) {
    $targetUserFolders = Get-ChildItem -Path $targetUserdataPath -Directory | Where-Object { $_.Name -match '^\d+$' }
    
    if ($targetUserFolders.Count -gt 0) {
        foreach ($userFolder in $targetUserFolders) {
            $userId = $userFolder.Name
            
            # копирование localconfig.vdf
            if (Test-Path $embedLocalconfig) {
                $destLocalDir = Join-Path $userFolder.FullName "config"
                if (-not (Test-Path $destLocalDir)) {
                    New-Item -ItemType Directory -Path $destLocalDir -Force | Out-Null
                }
                Copy-Item -Path $embedLocalconfig -Destination (Join-Path $destLocalDir "localconfig.vdf") -Force
                Write-Host "[+] Применен localconfig.vdf для аккаунта: $userId" -ForegroundColor Green
            } else {
                Write-Host "[Ошибка] Встроенный localconfig.vdf не найден в ресурсах проекта." -ForegroundColor Red
            }

            # копирование sharedconfig.vdf
            if (Test-Path $embedSharedconfig) {
                $destSharedDir = Join-Path $userFolder.FullName "7\remote"
                if (-not (Test-Path $destSharedDir)) {
                    New-Item -ItemType Directory -Path $destSharedDir -Force | Out-Null
                }
                Copy-Item -Path $embedSharedconfig -Destination (Join-Path $destSharedDir "sharedconfig.vdf") -Force
                Write-Host "[+] Применен sharedconfig.vdf для аккаунта: $userId" -ForegroundColor Green
            } else {
                Write-Host "[Ошибка] Встроенный sharedconfig.vdf не найден в ресурсах проекта." -ForegroundColor Red
            }
        }
    } else {
        Write-Host ""
        Write-Host "[Внимание] Папки аккаунтов в userdata не найдены." -ForegroundColor Yellow
        Write-Host "Пожалуйста, войдите в свой аккаунт в Steam хотя бы один раз, чтобы клиент создал нужные папки, затем запустите этот пункт меню снова." -ForegroundColor Yellow
    }
} else {
    Write-Host "[Ошибка] Папка userdata не найдена в каталоге Steam." -ForegroundColor Red
}

Write-Host ""
# 3. Применение дополнительных твиков реестра для Steam
Write-Host "Применение твиков производительности Steam в реестре..." -ForegroundColor Yellow
$registryPath = "HKCU:\Software\Valve\Steam"
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}
$tweaks = @{
    "GPUAccelWebViews" = 0
    "GPUAccelWebViewsV2" = 0
    "GPUAccelWebViewsV3" = 0
    "SmoothScrollWebViews" = 0
    "HardwareVideoDecoding" = 0
}
foreach ($tweak in $tweaks.GetEnumerator()) {
    New-ItemProperty -Path $registryPath -Name $tweak.Key -Value $tweak.Value -PropertyType DWORD -Force | Out-Null
}
Write-Host "[+] Отключено аппаратное ускорение веб-интерфейса Steam" -ForegroundColor Green
Write-Host "[+] Отключена плавная прокрутка веб-страниц Steam" -ForegroundColor Green
Write-Host "[+] Отключено аппаратное декодирование видео в Steam" -ForegroundColor Green

Write-Host ""
Write-Host "Все настройки Steam успешно применены!" -ForegroundColor Green
Write-Host "Теперь вы можете снова запустить Steam." -ForegroundColor Yellow
