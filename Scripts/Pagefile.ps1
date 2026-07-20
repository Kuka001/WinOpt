param([string]$Mode)
try {
    # Определение системного накопителя и пути (например, C:)
    $systemDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
    $pagefilePath = "$systemDrive\pagefile.sys"

    # Получение настроек системы через CIM
    $sys = Get-CimInstance -ClassName Win32_ComputerSystem
    
    if ($Mode -eq "Auto") {
        if (-not $sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $true
            Set-CimInstance -InputObject $sys | Out-Null
        }
        Write-Host "Автоматическое управление размером файла подкачки включено." -ForegroundColor Green
    } else {
        # Отключаем автоматический режим, если он включен
        if ($sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $false
            Set-CimInstance -InputObject $sys | Out-Null
        }

        # Получаем текущие параметры файла подкачки
        $pfSettings = Get-CimInstance -ClassName Win32_PageFileSetting

        if ($Mode -eq "None") {
            if ($pfSettings) {
                $pfSettings | Remove-CimInstance
            }
            Write-Host "Файл подкачки полностью отключен." -ForegroundColor Yellow
        } else {
            $sz = [int]$Mode
            
            if (-not $pfSettings) {
                # Создаем новый файл подкачки на системном диске, если файлов не было вообще
                New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                    Name = $pagefilePath
                    InitialSize = $sz
                    MaximumSize = $sz
                } | Out-Null
            } else {
                # Настраиваем размер файла подкачки на системном диске,
                # а также удаляем лишние файлы подкачки на других дисках
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
                
                # Если на системном диске файл подкачки не найден, создаем его
                if (-not $systemDriveFound) {
                    New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                        Name = $pagefilePath
                        InitialSize = $sz
                        MaximumSize = $sz
                    } | Out-Null
                }
            }
            Write-Host "Размер файла подкачки успешно зафиксирован: $sz MB на диске $systemDrive." -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Ошибка настройки файла подкачки: $($_.Exception.Message)" -ForegroundColor Red
}