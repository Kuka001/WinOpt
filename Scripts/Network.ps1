Write-Host "[1/6] Отключение RSC и вредных функций..." -ForegroundColor Yellow
# Настройки RSC (Receive Segment Coalescing - объединение сегментов)
Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Disable -EA 0
Set-NetOffloadGlobalSetting -PacketCoalescingFilter Disable -EA 0

# Оптимизация параметров TCP/IP стека
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh interface tcp set heuristics disabled | Out-Null
netsh int tcp set supplemental template=internet congestionprovider=ctcp | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null
netsh int tcp set global initialRto=300 | Out-Null

Write-Host "[2/6] Настройка NDIS параметров..." -ForegroundColor Yellow
$np = "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters"
if(!(Test-Path $np)){New-Item $np -Force|Out-Null}
@{DisableNDISWatchDog=1;DisableNaps=1;NoPauseOnSuspend=1;DebugLoggingMode=0;DisableWDIWatchdogForceBugcheck=1;DisableReenumerationTimeoutBugcheck=1;EnableNicAutoPowerSaverInSleepStudy=0}.GetEnumerator()|ForEach-Object{Set-ItemProperty $np $_.Key $_.Value -Type DWord}

Write-Host "[3/6] Настройка системного профиля задержек..." -ForegroundColor Yellow
$sysprofile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if(!(Test-Path $sysprofile)){New-Item $sysprofile -Force|Out-Null}
Set-ItemProperty $sysprofile "NetworkThrottlingIndex" 0xffffffff -Type DWord -Force -EA 0
Set-ItemProperty $sysprofile "SystemResponsiveness" 0 -Type DWord -Force -EA 0

Write-Host "[4/6] Настройка параметров сетевых адаптеров..." -ForegroundColor Yellow
$nc = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"

# Поиск и фильтрация физических сетевых адаптеров (Ethernet + Wi-Fi) по характеристикам
$adapters = Get-ChildItem $nc -ErrorAction SilentlyContinue | Where-Object {
    $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -EA 0).DriverDesc
    $char = (Get-ItemProperty $_.PSPath -Name "Characteristics" -EA 0).Characteristics
    
    ($_.PSChildName -match '^\d{4}$') -and 
    ($desc -ne $null) -and 
    ($char -ne $null) -and 
    (($char -band 4) -eq 4)
}

$ps = @{
# Энергосбережение (отключение для стабильности линка)
"*DeviceSleepOnDisconnect"="0";"*WakeOnMagicPacket"="0";"*WakeOnPattern"="0";"*NicAutoPowerSaver"="0"
"EEELinkAdvertisement"="0";"EnableModernStandby"="0";"EnablePowerManagement"="0";"EnablePME"="0"
"WakeFromS5"="0";"WakeOnLink"="0";"EnableETW"="0";"*EEE"="0";"DMACoalescing"="0"
"ReduceSpeedOnPowerDown"="0";"*EnableDynamicPowerGating"="0";"EnableD3ColdInS0"="0"
"*SelectiveSuspend"="0";"AdvancedEEE"="0";"ASPM"="0";"CLKREQ"="0";"EEEPlus"="0";"EnableAspm"="0"
"DynamicLTR"="0";"EnableGreenEthernet"="0";"GigaLite"="0";"PowerDownPll"="0";"PowerSavingMode"="0"
"WolShutdownLinkSpeed"="2";"LTROBFF"="0";"S0MgcPkt"="0";"S5WakeOnLan"="0"

# Разгрузка процессора (LSO/USO отключены для снижения инпут лага и задержек)
"*EncapsulatedPacketTaskOffloadNvgre"="0"
"*EncapsulatedPacketTaskOffloadVxlan"="0"
"*EncapsulatedPacketTaskOffload"="0"
"*LsoV1IPv4"="0";"*LsoV2IPv4"="0";"*LsoV2IPv6"="0";"*UsoIPv4"="0";"*UsoIPv6"="0"

# Выгрузка чексумм (включаем для аппаратного просчета сетевой картой)
"*IPChecksumOffloadIPv4"="3";"*TCPChecksumOffloadIPv4"="3";"*TCPChecksumOffloadIPv6"="3"
"*UDPChecksumOffloadIPv4"="3";"*UDPChecksumOffloadIPv6"="3";"*IPsecOffloadV2"="3"
"*TCPUDPChecksumOffloadIPv4"="3";"*TCPUDPChecksumOffloadIPv6"="3"

# RSS (Масштабирование на стороне приема - распределение по ядрам)
"*Rss"="1";"*NumRssQueues"="2";"RssV2"="1";"*VMQ"="0";"*FlowControl"="0"

# RSC (Объединение сегментов при приеме - отключаем для уменьшения потерь и стабильности пинга)
"*RscIPv4"="0";"*RscIPv6"="0";"ForceRscEnabled"="0";"*UdpRsc"="0"

# Модерация прерываний и буферы
"*InterruptModeration"="1" # Умеренная модерация прерываний для баланса задержек и FPS
"*JumboPacket"="1514";"*HeaderDataSplit"="1"
"*ReceiveBuffers"="1024" # Оптимальные буферы для исключения Bufferbloat
"*TransmitBuffers"="1024" 
"*PacketCoalescing"="0";"*PacketDirect"="1";"*NdisPoll"="1";"*SRIOV"="0"

# Настройки для чипов Intel
"I218DisablePLLShut"="1";"I218DisablePLLShutGiga"="1";"I219DisableK1Off"="1"
"DisableDelayedPowerUp"="1";"ForceHostExitUlp"="1";"ForceLtrValue"="0"
"EnableSavePowerNow"="0";"AutoPowerSaveModeEnabled"="0";"SipsEnabled"="0"
"LinkNegotiationProcess"="0";"DisableIntelRST"="1";"DisablePhyReset"="1"
"StoreBadPackets"="0";"RecvCompletionMethod"="4";"SendCompletionMethod"="2"
"ThreadPoll"="200000";"DropHighlyFragmentedPacket"="1";"EnableCoalesce"="0"
"DisableLLDP"="1";"HDSplitAlways"="1";"TeredoOffload"="1"
}
$pd = @{HwOption=0x00C00000;HwOptionV2=0x00000004;HwOptionV3=0x00040000}

$found = 0
foreach($a in $adapters){
    $rp = $a.PSPath
    $desc = (Get-ItemProperty $rp "DriverDesc" -EA 0).DriverDesc
    Write-Host " -> $desc" -ForegroundColor Cyan
    foreach($k in $ps.Keys){Set-ItemProperty $rp $k $ps[$k] -Type String -Force -EA 0}
    foreach($k in $pd.Keys){Set-ItemProperty $rp $k $pd[$k] -Type DWord -Force -EA 0}
    $found++
}
if($found -eq 0){Write-Host "Сетевые адаптеры не найдены." -ForegroundColor Red}
else{Write-Host "Оптимизировано адаптеров: $found" -ForegroundColor Green}

Write-Host "[5/6] Настройка параметров TCP/IP интерфейсов (снижение пинга)..." -ForegroundColor Yellow
$interfaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA 0
foreach($i in $interfaces){
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -EA 0
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -EA 0
    Set-ItemProperty -Path $i.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -EA 0
}
$msmq = "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters"
if(!(Test-Path $msmq)){New-Item $msmq -Force|Out-Null}
Set-ItemProperty $msmq "TCPNoDelay" 1 -Type DWord -Force -EA 0

Write-Host "[6/6] Настройка индикатора сети (NCSI) и приоритета IPv4..." -ForegroundColor Yellow
# Настройка Active Probing для корректного отображения статуса сети
$ncsiPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"
if (Test-Path $ncsiPath) {
    Set-ItemProperty -Path $ncsiPath -Name "EnableActiveProbing" -Value 1 -Type DWord -Force -EA 0
    # На всякий случай сбрасываем стандартные параметры веб-зондов Microsoft
    Set-ItemProperty -Path $ncsiPath -Name "ActiveWebProbeHost" -Value "www.msftconnecttest.com" -Type String -Force -EA 0
    Set-ItemProperty -Path $ncsiPath -Name "ActiveWebProbePath" -Value "connecttest.txt" -Type String -Force -EA 0
    Set-ItemProperty -Path $ncsiPath -Name "ActiveWebProbeContent" -Value "Microsoft Connect Test" -Type String -Force -EA 0
    Set-ItemProperty -Path $ncsiPath -Name "ActiveDnsProbeHost" -Value "dns.msftncsi.com" -Type String -Force -EA 0
    Set-ItemProperty -Path $ncsiPath -Name "ActiveDnsProbeContent" -Value "131.107.255.255" -Type String -Force -EA 0
    
    # Уменьшаем таймаут веб-зондов для ускорения инициализации статуса сети (по умолчанию 35 секунд)
    Set-ItemProperty -Path $ncsiPath -Name "WebTimeout" -Value 5 -Type DWord -Force -EA 0
}

# Удаление блокирующих политик NCSI, если они были заданы
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator"
if (Test-Path $policyPath) {
    Remove-ItemProperty -Path $policyPath -Name "NoActiveProbe" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $policyPath -Name "DisablePassivePolling" -Force -ErrorAction SilentlyContinue
}

# Решение проблемы "Без подключения к интернету" при включенном IPv6 без внешнего маршрута (приоритет IPv4)
$tcpip6Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
if (Test-Path $tcpip6Path) {
    # Установка DisabledComponents в значение 32 (0x20) - предпочитать IPv4 перед IPv6
    Set-ItemProperty -Path $tcpip6Path -Name "DisabledComponents" -Value 32 -Type DWord -Force -EA 0
}

# Сброс кэша DNS
Clear-DnsClientCache -ErrorAction SilentlyContinue