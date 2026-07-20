# === WHITELIST: Список приложений не подлежащих удалению ===
# Примечание: Xbox, GameBar, Калькулятор, Фотографии, Paint
$White = @(
    "*WindowsStore*",
    "*ScreenSketch*",
    "*WindowsNotepad*",
    "*WindowsTerminal*",
    "*VCLibs*",
    "*NET.Native*",
    "*UI.Xaml*",
    "*DesktopAppInstaller*",
    "*StorePurchaseApp*",
    "*HEIFImageExtension*",
    "*VP9VideoExtensions*",
    "*WebMediaExtensions*",
    "*WebpImageExtension*",
    "*ShellExperienceHost*",
    "*StartMenuExperienceHost*",
    "*Windows.Search*",
    "*CloudExperienceHost*",
    "*SecHealthUI*",
    "*WebView2*",
    "*EdgeWeb*",
    "*EdgeCore*"
)

function Test-White($n){foreach($p in $White){if($n -like $p){return $true}};return $false}

Write-Host "--- ГЛУБОКАЯ ОЧИСТКА WINDOWS (Избавление от мусора) ---" -ForegroundColor Green

# 1. Удаление UWP-приложений
Write-Host "`nШаг 1: Удаление UWP-приложений..." -ForegroundColor Cyan
$removed = 0
Get-AppxPackage -AllUsers | Where-Object {-not(Test-White $_.Name)} | ForEach-Object {
    Write-Host "  Удаление: $($_.Name)" -ForegroundColor Yellow
    Remove-AppxPackage -Package $_.PackageFullName -AllUsers -EA SilentlyContinue
    $removed++
}
Write-Host "  Удалено приложений: $removed" -ForegroundColor Gray

# 2. Удаление заготовок (Deprovision)
Write-Host "`nШаг 2: Удаление заготовок..." -ForegroundColor Cyan
Get-AppxProvisionedPackage -Online | Where-Object {-not(Test-White $_.DisplayName)} | ForEach-Object {
    Write-Host "  Удаление заготовки: $($_.DisplayName)" -ForegroundColor Yellow
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -EA SilentlyContinue
}

# 3. Удаление Microsoft Edge (WebView2 сохраняется)
Write-Host "`nШаг 3: Удаление Microsoft Edge..." -ForegroundColor Cyan

$edgeUWP = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
$unKey = $null
$selectedView = $null
$selectedMS = $null

# Поиск Edge в ветках реестра (64-бит и 32-бит)
foreach ($view in ([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
    $ms = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $view).OpenSubKey('SOFTWARE\Microsoft', $true)
    if ($ms) {
        $key = $ms.OpenSubKey('Windows\CurrentVersion\Uninstall\Microsoft Edge')
        if ($key) {
            $unKey = $key
            $selectedView = $view
            $selectedMS = $ms
            break
        }
    }
}

if($unKey){
    try{
        $uns = $unKey.GetValue('UninstallString') + ' --force-uninstall'
        $tp = if(Test-Path "$env:SystemRoot\SystemTemp"){"$env:SystemRoot\SystemTemp"}
              else{(New-Item "$env:TEMP\edge_remove_$(Get-Random)" -ItemType Directory -Force).FullName}
        $fake = "$tp\dllhost.exe"
        $selectedMS.CreateSubKey('EdgeUpdateDev').SetValue('AllowUninstall','')
        Copy-Item "$env:SystemRoot\System32\cmd.exe" $fake -Force
        [void](New-Item $edgeUWP -ItemType Directory -EA 0)
        [void](New-Item "$edgeUWP\MicrosoftEdge.exe" -EA 0)
        Start-Process $fake "/c $uns" -WindowStyle Hidden -Wait
        Remove-Item "$edgeUWP\MicrosoftEdge.exe" -EA 0
        Remove-Item $fake -EA 0
        Write-Host "  Edge успешно удален. WebView2 сохранен!" -ForegroundColor Green
    }catch{Write-Warning "Не удалось удалить Edge: $_"}
}else{Write-Host "  Edge не найден в системе (уже удален?)." -ForegroundColor Gray}

# 4. Удаление OneDrive
Write-Host "`nШаг 4: Удаление OneDrive..." -ForegroundColor Cyan
try{
    $odProc = Get-Process "OneDrive" -EA 0
    if($odProc){
        Stop-Process -Name "OneDrive" -Force -EA 0
        $deadline = (Get-Date).AddSeconds(5)
        while((Get-Process "OneDrive" -EA 0) -and (Get-Date) -lt $deadline){Start-Sleep -Milliseconds 200}
    }
    $od = @("$env:ProgramFiles\Microsoft OneDrive\OneDriveSetup.exe",
            "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
            "$env:SystemRoot\System32\OneDriveSetup.exe")
    $uninstalled = $false
    foreach($p in $od){
        if(Test-Path $p){
            Start-Process $p "/uninstall" -Wait -WindowStyle Hidden
            $uninstalled = $true
            break
        }
    }
    if($uninstalled){
        Start-Sleep 3
        @("$env:LocalAppData\Microsoft\OneDrive",
          "$env:ProgramData\Microsoft OneDrive",
          "$env:SystemDrive\OneDriveTemp") | Where-Object {Test-Path $_} | Remove-Item -Recurse -Force -EA 0
        Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -EA 0
        @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
          "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") | Where-Object {Test-Path $_} | Remove-Item -Recurse -Force -EA 0
        Write-Host "  OneDrive успешно удален." -ForegroundColor Green
    }else{Write-Host "  OneDrive не найден." -ForegroundColor Gray}
}catch{Write-Warning "Ошибка удаления OneDrive: $_"}

# 5. Удаление Outlook
Write-Host "`nШаг 5: Удаление нового Outlook..." -ForegroundColor Cyan
$outlook = Get-AppxPackage *OutlookForWindows* -AllUsers -EA 0
if($outlook){
    $outlook | Remove-AppxPackage -AllUsers -EA SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*OutlookForWindows*"} |
        Remove-AppxProvisionedPackage -Online -EA SilentlyContinue
    Write-Host "  Outlook (new) удален." -ForegroundColor Green
}else{Write-Host "  Outlook (new) не найден." -ForegroundColor Gray}

# 6. Отключение удаленного доступа
Write-Host "`nШаг 6: Отключение удаленного доступа..." -ForegroundColor Cyan
try{
    Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Remote Assistance" "fAllowToGetHelp" 0 -EA 0
    Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Remote Assistance" "fAllowFullControl" 0 -EA 0
    Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 1 -EA 0
    "SessionEnv","TermService","UmRdpService" | ForEach-Object {
        Stop-Service $_ -Force -EA 0
        Set-Service $_ -StartupType Disabled -EA 0
    }
    $qa = Get-WindowsCapability -Online -EA 0 | Where-Object {$_.Name -like "*QuickAssist*" -and $_.State -eq "Installed"}
    if($qa){Remove-WindowsCapability -Online -Name $qa.Name -EA 0}
    Write-Host "  Удаленный доступ успешно отключен." -ForegroundColor Green
}catch{Write-Warning "Ошибка: $_"}

# 7. Остановка и отключение служб Xbox и Gaming Services
Write-Host "`nШаг 7: Остановка и отключение служб Xbox и Gaming Services..." -ForegroundColor Cyan
$XboxServices = @(
    "XblAuthManager",      # Xbox Live Auth Manager
    "XblGameSave",         # Xbox Live Game Save
    "XboxNetApiSvc",       # Xbox Live Networking Service
    "XboxGipSvc",          # Xbox Accessory Management Service
    "GamingServices",      # Игровые службы Microsoft (Gaming Services)
    "GamingServicesNet"    # Игровые службы сети
)

foreach ($svc in $XboxServices) {
    if (Get-Service $svc -ErrorAction SilentlyContinue) {
        Write-Host "  Остановка и отключение службы: $svc" -ForegroundColor Yellow
        Stop-Service $svc -Force -EA SilentlyContinue
        Set-Service $svc -StartupType Disabled -EA SilentlyContinue
    }
}

# 8. Настройка параметров Game DVR и Game Bar в реестре
Write-Host "`nШаг 8: Настройка Game DVR и Game Bar в реестре..." -ForegroundColor Cyan
try {
    # Отключение игрового режима DVR (Game DVR)
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force -EA 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -EA 0
    
    # Отключение панели Game Bar
    $GameDVRKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
    if (-not (Test-Path $GameDVRKey)) { New-Item -Path $GameDVRKey -Force -EA 0 | Out-Null }
    Set-ItemProperty -Path $GameDVRKey -Name "AppCaptureEnabled" -Value 0 -Force -EA 0
    
    # Отключение всплывающих подсказок для игрового режима настройки/производительности
    $GameBarKey = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $GameBarKey)) { New-Item -Path $GameBarKey -Force -EA 0 | Out-Null }
    Set-ItemProperty -Path $GameBarKey -Name "AllowAutoGameMode" -Value 0 -Force -EA 0
    
    Write-Host "  Game DVR, Game Bar и параметры игрового режима успешно изменены." -ForegroundColor Green
} catch {
    Write-Warning "Не удалось настроить параметры для Game DVR: $_"
}

Write-Host "`n--- ОЧИСТКА ЗАВЕРШЕНА ---" -ForegroundColor Green