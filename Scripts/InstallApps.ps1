# =====================================================================
# Скачивание программ: WinGet + Резервный метод (curl / WebClient)
# Скачивание производится в папку MyProgramsEXE рядом с Start.bat
# =====================================================================

param(
    [string]$AppId
)

Clear-Host
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$scriptParent = Split-Path -Parent $PSScriptRoot
$targetDir = Join-Path $scriptParent "MyProgramsEXE"

if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory | Out-Null
}

Write-Host "Целевая папка для сохранения: $targetDir" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray

# Функция проверки и принудительного запуска необходимых служб для winget
function Enable-WingetServices {
    $services = @("ClipSVC", "InstallService", "DoSvc")
    foreach ($svc in $services) {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s) {
            if ($s.StartType -eq "Disabled") {
                Write-Host "Включение службы $svc..." -ForegroundColor Gray
                Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
            }
            if ($s.Status -ne "Running") {
                Write-Host "Запуск службы $svc..." -ForegroundColor Gray
                Start-Service -Name $svc -ErrorAction SilentlyContinue
            }
        }
    }
}

# Функция исправления ошибок баз данных источников WinGet (0x8a15000f) под администратором
function Repair-Winget {
    Write-Host "Обнаружены проблемы с базой данных источников WinGet (ошибка 0x8a15000f)." -ForegroundColor Yellow
    Write-Host "Запуск автоматического исправления..." -ForegroundColor Yellow
    
    # Включаем службы перед исправлением
    Enable-WingetServices

    # 1. Попытка перерегистрации системного источника для текущего профиля (Администратор)
    try {
        Write-Host "Регистрация Microsoft.Winget.Source..." -ForegroundColor Gray
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.Winget.Source_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Не удалось зарегистрировать через AppX (пропускаем)..." -ForegroundColor Gray
    }

    # 2. Сброс и принудительное обновление источников
    Write-Host "Принудительный сброс источников WinGet..." -ForegroundColor Gray
    $null = Start-Process "winget" -ArgumentList "source reset --force" -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
    Write-Host "Обновление источников..." -ForegroundColor Gray
    $null = Start-Process "winget" -ArgumentList "source update" -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
}

# Функция проверки работоспособности winget и его источников
function Test-Winget {
    $wingetExists = Get-Command "winget" -ErrorAction SilentlyContinue
    if (-not $wingetExists) { return $false }
    
    # Проверка работоспособности самого исполняемого файла
    try {
        $p = Start-Process "winget" -ArgumentList "--version" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
        if ($p.ExitCode -ne 0) { return $false }
    } catch {
        return $false
    }

    # Проверка работоспособности источников (защита от ошибки 0x8a15000f)
    Write-Host "Проверка связи с источниками WinGet..." -ForegroundColor Gray
    $pSources = Start-Process "winget" -ArgumentList "search Google.Chrome --accept-source-agreements" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
    if ($pSources.ExitCode -ne 0) {
        # Если источники поломаны, пробуем восстановить их
        Repair-Winget
        
        # Проверяем источники еще раз после исправления
        $pSources = Start-Process "winget" -ArgumentList "search Google.Chrome --accept-source-agreements" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
        if ($pSources.ExitCode -ne 0) {
            Write-Host "[Предупреждение] Источники WinGet не удалось восстановить автоматически." -ForegroundColor Red
            Write-Host "Будет использован резервный метод скачивания (curl)." -ForegroundColor DarkYellow
            return $false
        }
    }
    
    return $true
}

$IsWingetAvailable = Test-Winget

# Описание приложений: [Имя, ID в WinGet, URL для curl, имя целевого файла, специальные заголовки для curl]
$apps = @{
    "1"  = @("Google Chrome", "Google.Chrome", "https://dl.google.com/chrome/install/ChromeStandaloneSetup64.exe", "chrome_setup.exe", "")
    "2"  = @("Steam", "Valve.Steam", "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe", "steam_setup.exe", "")
    "3"  = @("Faceit Anti-Cheat", "", "https://client.anti-cheat.faceit.com/FACEITAC.exe", "faceit_ac_setup.exe", "")
    "4"  = @("7-Zip", "7zip.7zip", "https://www.7-zip.org/a/7z2409-x64.exe", "7z_setup.exe", "")
    "5"  = @("KMPlayer", "", "https://dn.kmplayer.com/Dn/kmp64x/KMP64_2026.6.26.11.exe", "kmp_setup.exe", "")
    "6"  = @("Honeyview", "Bandisoft.Honeyview", "https://www.bandisoft.com/honeyview/dl.php?web", "honeyview_setup.exe", "")
    "7"  = @("Cloudflare WARP (1.1.1.1)", "Cloudflare.Warp", "https://1.1.1.1/Cloudflare_WARP_Release-x64.msi", "cloudflare_warp_setup.msi", "")
    "8"  = @("AIDA64 Extreme", "FinalWire.AIDA64.Extreme", "https://download.aida64.com/aida64extreme730.exe", "aida64_setup.exe", "")
    "9"  = @("MSI Afterburner", "Guru3D.Afterburner", "https://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip", "MSIAfterburnerSetup.zip", "")
    "10" = @("Revo Uninstaller", "VSRevoGroup.RevoUninstaller", "https://download.revouninstaller.com/download/RevoUninProSetup.exe", "revo_setup.exe", "")
    "11" = @("NVCleanstall", "TechPowerUp.NVCleanstall", "majorgeeks", "NVCleanstall_setup.exe", "")
    "12" = @("Autoruns (Sysinternals)", "Microsoft.Sysinternals.Autoruns", "https://download.sysinternals.com/files/Autoruns.zip", "Autoruns.zip", "")
    "13" = @("NVIDIA Profile Inspector", "Orbmu2k.nvidiaProfileInspector", "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip", "nvidiaProfileInspector.zip", "")
}

# Функция скачивания через curl
function Download-Curl {
    param(
        [string]$Name,
        [string]$Url,
        [string]$FileName,
        [string]$ExtraArgs
    )
    
    $destPath = Join-Path $targetDir $FileName
    if (Test-Path $destPath) { Remove-Item $destPath -Force -ErrorAction SilentlyContinue | Out-Null }
    
    if ($Url -eq "majorgeeks") {
        Write-Host "Парсинг зеркала MajorGeeks для $Name..." -ForegroundColor Gray
        $pStart = New-Object System.Diagnostics.ProcessStartInfo
        $pStart.FileName = "curl.exe"
        $pStart.Arguments = "-s -L -k -A `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36`" `"https://www.majorgeeks.com/mg/getmirror/nvcleanstall,1.html`""
        $pStart.UseShellExecute = $false
        $pStart.RedirectStandardOutput = $true
        $pStart.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($pStart)
        $html = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()

        $matchLink = [regex]::Match($html, 'href="(https://files\d*\.majorgeeks\.com/[^"]+NVCleanstall[^"]*\.exe)"')
        if (-not $matchLink.Success) {
            $matchLink = [regex]::Match($html, 'href="(https://[^"]+NVCleanstall[^"]*\.exe)"')
        }
        if ($matchLink.Success) {
            $Url = $matchLink.Groups[1].Value
            $ExtraArgs = "-A `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36`" -H `"Referer: https://www.majorgeeks.com/`""
        } else {
            Write-Host "Не удалось распарсить ссылку MajorGeeks. Используем TechPowerUp напрямую..." -ForegroundColor DarkYellow
            $Url = "https://www.techpowerup.com/download/techpowerup-nvcleanstall/"
            $ExtraArgs = "-A `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36`""
        }
    }
    
    Write-Host ">>> Скачивание: $Name (резервный метод)..." -ForegroundColor Yellow

    $curlArgs = "-L -k --retry 3 --retry-delay 2 -o `"$destPath`" `"$Url`""
    if ($ExtraArgs) {
        $curlArgs = "$ExtraArgs $curlArgs"
    } else {
        $curlArgs = "-A `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36`" $curlArgs"
    }

    $p = Start-Process "curl.exe" -ArgumentList $curlArgs -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue

    if ($p.ExitCode -eq 0 -and (Test-Path $destPath) -and (Get-Item $destPath).Length -gt 10240) {
        $header = [byte[]]::new(2)
        $stream = [System.IO.File]::OpenRead($destPath)
        $null = $stream.Read($header, 0, 2)
        $stream.Close()
        $isMZ = ($header[0] -eq 0x4D -and $header[1] -eq 0x5A)
        $isPK = ($header[0] -eq 0x50 -and $header[1] -eq 0x4B)
        $isMSI = ($FileName.EndsWith(".msi"))

        if ($isMZ -or $isPK -or $isMSI) {
            Write-Host "Файл успешно сохранен: $FileName" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Ошибка: скачан некорректный файл (вероятно HTML-страница вместо установщика)." -ForegroundColor Red
            Remove-Item $destPath -Force -ErrorAction SilentlyContinue | Out-Null
            return $false
        }
    } else {
        if ($Name -eq "Faceit Anti-Cheat") {
            Write-Host "Ошибка при скачивании Faceit. Сбой подключения или блокировка DNS." -ForegroundColor Red
            Write-Host "[Справка] Домен FACEIT часто блокируется провайдерами РФ и РК. Попробуйте сменить DNS на 1.1.1.1 / 8.8.8.8 или включить VPN." -ForegroundColor DarkYellow
        } else {
            Write-Host "Ошибка скачивания $Name через curl (Код: $($p.ExitCode))." -ForegroundColor Red
        }
        return $false
    }
}


# Функция скачивания через winget
function Download-Winget {
    param(
        [string]$Name,
        [string]$WingetId,
        [string]$FileName
    )

    if (-not $IsWingetAvailable -or -not $WingetId) {
        return $false
    }

    # Убедимся, что необходимые службы включены и запущены перед работой winget
    Enable-WingetServices

    Write-Host ">>> Скачивание: $Name (через winget)..." -ForegroundColor Yellow

    $tempDir = Join-Path $env:TEMP "Winget_$($WingetId -replace '[^a-zA-Z0-9]','_')"
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue | Out-Null }
    New-Item -Path $tempDir -ItemType Directory | Out-Null

    $p = Start-Process "winget" -ArgumentList "download --id $WingetId -d `"$tempDir`" --accept-source-agreements --accept-package-agreements" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue

    # Попытка восстановления, если winget завершился с ошибкой (например, 0x8a15000f)
    if ($p.ExitCode -ne 0) {
        Write-Host "Предупреждение: скачивание через winget не удалось (код $($p.ExitCode)). Пробуем сбросить и обновить источники..." -ForegroundColor Yellow
        $null = Start-Process "winget" -ArgumentList "source reset --force" -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
        $null = Start-Process "winget" -ArgumentList "source update" -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
        
        # Вторая попытка скачать после сброса источников
        Write-Host "Повторная попытка скачивания через winget..." -ForegroundColor Yellow
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue | Out-Null }
        New-Item -Path $tempDir -ItemType Directory | Out-Null
        $p = Start-Process "winget" -ArgumentList "download --id $WingetId -d `"$tempDir`" --accept-source-agreements --accept-package-agreements" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
    }

    $success = $false
    if ($p.ExitCode -eq 0) {
        $installer = Get-ChildItem -Path $tempDir -File -Recurse | Where-Object { $_.Extension -in ".exe", ".msi", ".zip", ".msix", ".msixbundle" } | Select-Object -First 1
        if ($installer) {
            $destPath = Join-Path $targetDir $FileName
            if (Test-Path $destPath) { Remove-Item $destPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Move-Item -Path $installer.FullName -Destination $destPath -Force | Out-Null
            Write-Host "Файл успешно скачан: $FileName" -ForegroundColor Green
            $success = $true
        } else {
            Write-Host "Установщик не найден в скачанном пакете." -ForegroundColor Red
        }
    } else {
        Write-Host "winget download не удался (код: $($p.ExitCode)), переход к резервному методу..." -ForegroundColor DarkYellow
    }

    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue | Out-Null }
    return $success
}

# Функция обработки архивов
function Handle-Zip {
    param(
        [string]$Name,
        [string]$ZipPath
    )
    
    if ($Name -eq "Autoruns (Sysinternals)") {
        $destFolder = Join-Path $targetDir "Autoruns"
        if (Test-Path $destFolder) { Remove-Item $destFolder -Recurse -Force -ErrorAction SilentlyContinue }
        New-Item -Path $destFolder -ItemType Directory | Out-Null

        Write-Host "Распаковка Autoruns в папку: $destFolder..." -ForegroundColor Yellow
        try {
            Expand-Archive -Path $ZipPath -DestinationPath $destFolder -Force
            Write-Host "Autoruns успешно распакован!" -ForegroundColor Green
            Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Write-Host "Ошибка при распаковке Autoruns: $_" -ForegroundColor Red
        }
    }
    elseif ($Name -eq "NVIDIA Profile Inspector") {
        $destFolder = Join-Path $targetDir "NvidiaProfileInspector"
        if (Test-Path $destFolder) { Remove-Item $destFolder -Recurse -Force -ErrorAction SilentlyContinue }
        New-Item -Path $destFolder -ItemType Directory | Out-Null

        Write-Host "Распаковка NVIDIA Profile Inspector в папку: $destFolder..." -ForegroundColor Yellow
        try {
            Expand-Archive -Path $ZipPath -DestinationPath $destFolder -Force
            Write-Host "NVIDIA Profile Inspector успешно распакован!" -ForegroundColor Green
            Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Write-Host "Ошибка при распаковке NVIDIA Profile Inspector: $_" -ForegroundColor Red
        }
    }
    elseif ($Name -eq "MSI Afterburner") {
        $tempExtractDir = Join-Path $env:TEMP "MSI_Extract"
        if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
        New-Item -Path $tempExtractDir -ItemType Directory | Out-Null
        
        Write-Host "Распаковка установщика MSI Afterburner..." -ForegroundColor Yellow
        try {
            Expand-Archive -Path $ZipPath -DestinationPath $tempExtractDir -Force
            $exeFile = Get-ChildItem -Path $tempExtractDir -Filter "*.exe" -Recurse | Select-Object -First 1
            if ($exeFile) {
                $destExe = Join-Path $targetDir $exeFile.Name
                if (Test-Path $destExe) { Remove-Item $destExe -Force -ErrorAction SilentlyContinue | Out-Null }
                Move-Item -Path $exeFile.FullName -Destination $destExe -Force | Out-Null
                Write-Host "Установщик MSI Afterburner извлечен: $($exeFile.Name)" -ForegroundColor Green
                Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue | Out-Null
            } else {
                Write-Host "Ошибка: исполняемый файл установщика не найден в архиве." -ForegroundColor Red
            }
        } catch {
            Write-Host "Ошибка при распаковке MSI Afterburner: $_" -ForegroundColor Red
        } finally {
            if (Test-Path $tempExtractDir) { Remove-Item $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
        }
    }
}

function Execute-Download {
    param([string]$id)

    if (-not $apps.ContainsKey($id)) { return }

    $appInfo = $apps[$id]
    $name = $appInfo[0]
    $wingetId = $appInfo[1]
    $url = $appInfo[2]
    $fileName = $appInfo[3]
    $extraArgs = $appInfo[4]

    # Faceit Anti-Cheat: скачиваем напрямую с CDN (winget не работает от админа из-за hash override)
    if ($id -eq "3") {
        $faceitCdnUrl = "https://anticheat-client.faceit-cdn.net/FACEITInstaller_64.exe"
        $done = Download-Curl -Name $name -Url $faceitCdnUrl -FileName $fileName -ExtraArgs $extraArgs
        if (-not $done) {
            $done = Download-Curl -Name $name -Url $url -FileName $fileName -ExtraArgs $extraArgs
        }
        return
    }

    # 1. Пробуем скачать через winget download
    $done = Download-Winget -Name $name -WingetId $wingetId -FileName $fileName

    # 2. Если winget не сработал или недоступен, качаем через curl
    if (-not $done) {
        $done = Download-Curl -Name $name -Url $url -FileName $fileName -ExtraArgs $extraArgs
    }

    # 3. Если скачан архив, распаковываем его
    if ($done -and $fileName.EndsWith(".zip")) {
        Handle-Zip -Name $name -ZipPath (Join-Path $targetDir $fileName)
    }
}

if ($AppId -eq "all") {
    Write-Host "=== Запуск скачивания ВСЕХ файлов из списка ===" -ForegroundColor Cyan
    foreach ($key in ($apps.Keys | Sort-Object {[int]$_})) {
        Execute-Download -id $key
        Write-Host "----------------------------------------" -ForegroundColor Gray
    }
    Write-Host "Скачивание всех файлов завершено!" -ForegroundColor Cyan
} else {
    Execute-Download -id $AppId
}

Write-Host ""
Write-Host "Нажмите любую клавишу для продолжения..."
$null = [Console]::ReadKey($true)
