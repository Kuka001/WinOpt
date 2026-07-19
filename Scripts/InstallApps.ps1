# =====================================================================
# Скачивание программ: curl
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

# Описание приложений: [Имя, URL для curl, имя целевого файла, специальные заголовки для curl]
$apps = @{
    "1"  = @("Google Chrome", "https://dl.google.com/chrome/install/ChromeStandaloneSetup64.exe", "chrome_setup.exe", "")
    "2"  = @("Steam", "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe", "steam_setup.exe", "")
    "3"  = @("Faceit Anti-Cheat", "https://client.anti-cheat.faceit.com/FACEITAC.exe", "faceit_ac_setup.exe", "")
    "4"  = @("7-Zip", "https://www.7-zip.org/a/7z2409-x64.exe", "7z_setup.exe", "")
    "5"  = @("KMPlayer", "https://dn.kmplayer.com/Dn/kmp64x/KMP64_2026.6.26.11.exe", "kmp_setup.exe", "")
    "6"  = @("Honeyview", "https://www.bandisoft.com/honeyview/dl.php?web", "honeyview_setup.exe", "")
    "7"  = @("Cloudflare WARP (1.1.1.1)", "https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi", "cloudflare_warp_setup.msi", "")
    "8"  = @("AIDA64 Extreme", "https://download.aida64.com/aida64extreme730.exe", "aida64_setup.exe", "")
    "9"  = @("MSI Afterburner", "guru3d", "MSIAfterburnerSetup.zip", "")
    "10" = @("Revo Uninstaller", "https://download.revouninstaller.com/download/RevoUninProSetup.exe", "revo_setup.exe", "")
    "11" = @("NVCleanstall", "techpowerup", "NVCleanstall_setup.exe", "")
    "12" = @("Autoruns (Sysinternals)", "https://download.sysinternals.com/files/Autoruns.zip", "Autoruns.zip", "")
    "13" = @("NVIDIA Profile Inspector", "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip", "nvidiaProfileInspector.zip", "")
    "14" = @("Visual C++ Redistributable AIO (abbodi1406)", "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe", "VisualCppRedist_AIO_x86_x64.exe", "")
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
    
    if ($Url -eq "guru3d") {
        Write-Host "Парсинг Guru3D для $Name..." -ForegroundColor Gray
        $pStart = New-Object System.Diagnostics.ProcessStartInfo
        $pStart.FileName = "curl.exe"
        $pStart.Arguments = "-s -L -A `"Mozilla/5.0`" `"https://www.guru3d.com/download/msi-afterburner-beta-download/`""
        $pStart.UseShellExecute = $false
        $pStart.RedirectStandardOutput = $true
        $pStart.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($pStart)
        $html = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()

        $match = [regex]::Match($html, 'name="aform".*?value="([a-f0-9]+)"')
        if ($match.Success) {
            $val = $match.Groups[1].Value
            $pStart.Arguments = "-s -i -A `"Mozilla/5.0`" -d `"aform=$val`" `"https://www.guru3d.com/download/msi-afterburner-beta-download/mirrors`""
            $proc = [System.Diagnostics.Process]::Start($pStart)
            $headers = $proc.StandardOutput.ReadToEnd()
            $proc.WaitForExit()
            
            $locMatch = [regex]::Match($headers, 'href="(https://www.guru3d.com/getdownload/[a-f0-9]+)"')
            if ($locMatch.Success) {
                $downloadUrl = $locMatch.Groups[1].Value.Trim()
                $pStart.Arguments = "-s -i -A `"Mozilla/5.0`" `"$downloadUrl`""
                $proc = [System.Diagnostics.Process]::Start($pStart)
                $finalHeaders = $proc.StandardOutput.ReadToEnd()
                $proc.WaitForExit()
                
                $finalLocMatch = [regex]::Match($finalHeaders, '(?i)location:\s*(.+)')
                if ($finalLocMatch.Success) {
                    $Url = $finalLocMatch.Groups[1].Value.Trim()
                }
            }
        }
        if ($Url -eq "guru3d") {
            Write-Host "Не удалось распарсить ссылку Guru3D." -ForegroundColor Red
            return $false
        }
        $ExtraArgs = "-A `"Mozilla/5.0`""
    }
    
    if ($Url -eq "techpowerup") {
        Write-Host "Парсинг TechPowerUp для $Name..." -ForegroundColor Gray
        $pStart = New-Object System.Diagnostics.ProcessStartInfo
        $pStart.FileName = "curl.exe"
        $pStart.Arguments = "-s -L -A `"Mozilla/5.0`" `"https://www.techpowerup.com/download/techpowerup-nvcleanstall/`""
        $pStart.UseShellExecute = $false
        $pStart.RedirectStandardOutput = $true
        $pStart.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($pStart)
        $html = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()

        $match = [regex]::Match($html, '<input type="hidden" name="id" value="(\d+)" />')
        if ($match.Success) {
            $id = $match.Groups[1].Value
            $pStart.Arguments = "-s -i -A `"Mozilla/5.0`" -d `"id=$id&server_id=19`" `"https://www.techpowerup.com/download/techpowerup-nvcleanstall/`""
            $proc = [System.Diagnostics.Process]::Start($pStart)
            $headers = $proc.StandardOutput.ReadToEnd()
            $proc.WaitForExit()
            
            $locMatch = [regex]::Match($headers, '(?i)location:\s*(.+)')
            if ($locMatch.Success) {
                $Url = $locMatch.Groups[1].Value.Trim()
            }
        }
        if ($Url -eq "techpowerup") {
            Write-Host "Не удалось распарсить ссылку TechPowerUp." -ForegroundColor Red
            return $false
        }
        $ExtraArgs = "-A `"Mozilla/5.0`""
    }
    
    Write-Host ">>> Скачивание: $Name..." -ForegroundColor Yellow

    $curlArgs = "-L -k -g --retry 3 --retry-delay 2 -o `"$destPath`" `"$Url`""
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
    $url = $appInfo[1]
    $fileName = $appInfo[2]
    $extraArgs = $appInfo[3]

    # Faceit Anti-Cheat: скачиваем напрямую с CDN
    if ($id -eq "3") {
        $faceitCdnUrl = "https://anticheat-client.faceit-cdn.net/FACEITInstaller_64.exe"
        $done = Download-Curl -Name $name -Url $faceitCdnUrl -FileName $fileName -ExtraArgs $extraArgs
        if (-not $done) {
            $done = Download-Curl -Name $name -Url $url -FileName $fileName -ExtraArgs $extraArgs
        }
        return
    }

    $done = Download-Curl -Name $name -Url $url -FileName $fileName -ExtraArgs $extraArgs

    # Если скачан архив, распаковываем его
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
