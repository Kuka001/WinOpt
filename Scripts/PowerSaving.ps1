$results = [System.Collections.Generic.List[object]]::new()
function Add-R($A,$T,$S,$M){$null=$results.Add([pscustomobject]@{Area=$A;Target=$T;Success=$S;Message=$M})}

# ���� ����� ��������� PnP � �������������� CIM (������ Get-WmiObject ��� ������������� � PS 7)
$pnpMap = @{}
try {
    Get-CimInstance -ClassName Win32_PnPEntity -EA Stop | ForEach-Object {
        if ($_.PNPDeviceID -and -not $pnpMap.ContainsKey($_.PNPDeviceID)) {
            $pnpMap[$_.PNPDeviceID] = if ($_.Name) { $_.Name } else { $_.PNPDeviceID }
        }
    }
} catch {
    Add-R 'Env' 'Win32_PnPEntity' $false $_.Exception.Message
}

function Get-Label($Id){
    if(!$Id){return $Id}
    if($pnpMap.ContainsKey($Id)){return $pnpMap[$Id]}
    if($Id -match '^(.*)_\d+$' -and $pnpMap.ContainsKey($matches[1])){return $pnpMap[$matches[1]]}
    return $Id
}

# ���������� ���������������� ����� ���������� CIM (WMI)
function Do-CimDisable($Class,$Area){
    try {
        $items = @(Get-CimInstance -Namespace root\wmi -ClassName $Class -EA Stop)
    } catch {
        Add-R $Area $Class $false "Query: $($_.Exception.Message)"
        return
    }
    if(!$items){
        Add-R $Area $Class $true 'No devices'
        return
    }
    foreach($i in $items){
        $l = Get-Label $i.InstanceName
        try {
            if($i.Enable){
                $i.Enable = $false
                Set-CimInstance -InputObject $i -EA Stop | Out-Null
                Add-R $Area $l $true "Disabled"
            } else {
                Add-R $Area $l $true "Already off"
            }
        } catch {
            Add-R $Area $l $false $_.Exception.Message
        }
    }
}
Do-CimDisable 'MSPower_DeviceEnable' 'Allow turn-off to save power'
Do-CimDisable 'MSPower_DeviceWakeEnable' 'Allow wake computer'

# ��������� ����������� ��������� ����� powercfg
try {
    $wd = @(powercfg -devicequery wake_programmable 2>$null | Where-Object{$_ -and $_.Trim()})
    if($wd){
        foreach($d in $wd){
            $o = powercfg -devicedisablewake "$d" 2>&1
            $msg = if ($LASTEXITCODE -eq 0) { if ($o) { $o-join' ' } else { "Disabled" } } else { $o-join' ' }
            Add-R 'Wake powercfg' $d ($LASTEXITCODE-eq0) $msg
        }
    } else {
        Add-R 'Wake powercfg' 'wake_programmable' $true 'None found'
    }
} catch {
    Add-R 'Wake powercfg' 'powercfg' $false $_.Exception.Message
}

# ���������� ���������������� ������� ���������
try {
    Import-Module NetAdapter -EA Stop
} catch {
    Add-R 'NetAdapter PM' 'Module' $false $_.Exception.Message
}

if(Get-Command Disable-NetAdapterPowerManagement -EA 0){
    try {
        $adps = @(Get-NetAdapter -IncludeHidden -EA Stop)
    } catch {
        $adps = @()
    }
    foreach($a in $adps){
        $t = "$($a.Name)|$($a.InterfaceDescription)"
        try {
            # ���������, ������������ �� ������� ���������� �������� (��������� ����������� ����� ����� kdnic)
            $pm = $null
            try { $pm = Get-NetAdapterPowerManagement -Name $a.Name -EA Stop } catch {}
            
            if ($null -eq $pm) {
                Add-R 'NetAdapter PM' $t $true 'Not supported (Virtual)'
                continue
            }
            
            Disable-NetAdapterPowerManagement -Name $a.Name -IncludeHidden -EA Stop
            Add-R 'NetAdapter PM' $t $true 'Done'
        } catch {
            Add-R 'NetAdapter PM' $t $false $_.Exception.Message
        }
    }
}

# ���������� ���������� ���������������� � �������� ����� ������� ��
try {
    # ���������� PCI Express ASPM (���������������� ����)
    $null = powercfg -setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 2>&1
    $null = powercfg -setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 2>&1
    
    # ���������� USB Selective Suspend (���������� ������������ USB)
    $null = powercfg -setacvalueindex SCHEME_CURRENT SUB_USB usbenableprep 0 2>&1
    $null = powercfg -setdcvalueindex SCHEME_CURRENT SUB_USB usbenableprep 0 2>&1
    
    # ���������� ��������� �����
    $oActive = powercfg -setactive SCHEME_CURRENT 2>&1
    $msgActive = if ($LASTEXITCODE -eq 0) { if ($oActive) { $oActive-join' ' } else { "Applied successfully" } } else { $oActive-join' ' }
    Add-R 'Power Scheme' 'PCIe ASPM & USB Suspend' ($LASTEXITCODE-eq0) $msgActive
} catch {
    Add-R 'Power Scheme' 'Power Plan Global Config' $false $_.Exception.Message
}

# ��������� ���������� ������� ��� USB � Bluetooth-���������
$usbRoots = @('HKLM:\SYSTEM\CurrentControlSet\Enum\USB','HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR','HKLM:\SYSTEM\CurrentControlSet\Enum\USBPRINT','HKLM:\SYSTEM\CurrentControlSet\Enum\BTHUSB')
$usbVals = @('EnhancedPowerManagementEnabled','SelectiveSuspendEnabled','EnableSelectiveSuspend','AllowIdleIrpInD3')
$usbPaths = @()
foreach($r in $usbRoots){
    if(Test-Path $r){
        $usbPaths += @(Get-ChildItem $r -Recurse -EA 0 | Where-Object{$_.PSChildName-eq'Device Parameters'} | Select-Object -Expand PSPath)
    }
}
$usbPaths = @($usbPaths | Sort-Object -Unique)

foreach($path in $usbPaths){
    try {
        $ki = Get-Item $path -EA Stop
        $rel = $ki.Name -replace '^HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Enum\\',''
        $pnpId = $rel -replace '\\Device Parameters$',''
        $label = Get-Label $pnpId
        $notes = [System.Collections.Generic.List[string]]::new()
        $ok = $true
        foreach($vn in $usbVals){
            try {
                $exists = $ki.GetValueNames() -contains $vn
                if(!$exists){
                    New-ItemProperty $path $vn -PropertyType DWord -Value 0 -Force -EA Stop | Out-Null
                    $notes.Add("$vn=0 created")
                } else {
                    $kind = [string]$ki.GetValueKind($vn)
                    if($kind -ne 'DWord'){
                        Remove-ItemProperty $path $vn -Force -EA Stop
                        New-ItemProperty $path $vn -PropertyType DWord -Value 0 -Force -EA Stop | Out-Null
                        $notes.Add("$vn recreated")
                    } else {
                        $bv = $ki.GetValue($vn,$null,'DoNotExpandEnvironmentNames')
                        Set-ItemProperty $path $vn 0 -EA Stop
                        if($bv -eq 0){
                            $notes.Add("$vn ok")
                        } else {
                            $notes.Add("$($vn): $($bv)->0")
                        }
                    }
                }
            } catch {
                $ok = $false
                $notes.Add("$vn fail: $($_.Exception.Message)")
            }
        }
        Add-R 'USB registry' "$label|$pnpId" $ok ($notes -join '; ')
    } catch {
        Add-R 'USB registry' $path $false $_.Exception.Message
    }
}

# ����� ����������� ������
$areas = @('Allow turn-off to save power','Allow wake computer','Wake powercfg','NetAdapter PM','USB registry','Power Scheme','Env')
foreach($area in $areas){
    $grp = @($results | Where-Object{$_.Area-eq$area})
    if($grp.Count -gt 0){
        Write-Host "`n=== $area ==="
        foreach($e in $grp | Sort-Object Target){
            if($e.Success){
                Write-Host "[OK] $($e.Target) - $($e.Message)" -ForegroundColor Green
            } else {
                Write-Host "[FAIL] $($e.Target) - $($e.Message)" -ForegroundColor Red
            }
        }
    }
}
$sc = @($results | Where-Object{$_.Success}).Count
$fc = @($results | Where-Object{-not $_.Success}).Count
Write-Host "`n[RESULT] Success=$sc Failed=$fc" -ForegroundColor $(if($fc-eq0){'Green'}elseif($sc/($sc+$fc)-ge0.75){'Yellow'}else{'Red'})