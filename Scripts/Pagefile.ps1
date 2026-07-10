param([string]$Mode)
try {
    # Динамически определяем системный диск (например, C:)
    $systemDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
    $pagefilePath = "$systemDrive\pagefile.sys"

    # Получаем параметры системы через CIM
    $sys = Get-CimInstance -ClassName Win32_ComputerSystem
    
    if ($Mode -eq "Auto") {
        if (-not $sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $true
            Set-CimInstance -InputObject $sys | Out-Null
        }
        Write-Host "Автоматическое управление файлом подкачки включено." -ForegroundColor Green
    } else {
        # Отключаем автоуправление, если оно включено
        if ($sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $false
            Set-CimInstance -InputObject $sys | Out-Null
        }

        # Получаем текущие настройки файлов подкачки
        $pfSettings = Get-CimInstance -ClassName Win32_PageFileSetting

        if ($Mode -eq "None") {
            if ($pfSettings) {
                $pfSettings | Remove-CimInstance
            }
            Write-Host "Файл подкачки полностью отключён." -ForegroundColor Yellow
        } else {
            $sz = [int]$Mode
            
            if (-not $pfSettings) {
                # Создаем новый файл подкачки на системном диске, если настроек не было вовсе
                New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                    Name = $pagefilePath
                    InitialSize = $sz
                    MaximumSize = $sz
                } | Out-Null
            } else {
                # Настраиваем только один файл на системном диске, 
                # а файлы на других дисках удаляем во избежание дублирования места
                $systemDriveFound = $false
                foreach ($p in $pfSettings) {
                    if ($p.Name -like "$systemDrive*") {
                        $p.InitialSize = $sz
                        $p.MaximumSize = $sz
                        Set-CimInstance -InputObject $p | Out-Null
                        $systemDriveFound = $true
                    } else {
                        $p | Remove-CimInstance
                    }
                }
                
                # Если на системном диске файла не было, создаем его
                if (-not $systemDriveFound) {
                    New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                        Name = $pagefilePath
                        InitialSize = $sz
                        MaximumSize = $sz
                    } | Out-Null
                }
            }
            Write-Host "Файл подкачки жестко зафиксирован: $sz MB на диске $systemDrive." -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Ошибка настройки файла подкачки: $($_.Exception.Message)" -ForegroundColor Red
}