param([string]$Mode)
try {
    # ����������� ���������� ��������� ���� (��������, C:)
    $systemDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
    $pagefilePath = "$systemDrive\pagefile.sys"

    # �������� ��������� ������� ����� CIM
    $sys = Get-CimInstance -ClassName Win32_ComputerSystem
    
    if ($Mode -eq "Auto") {
        if (-not $sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $true
            Set-CimInstance -InputObject $sys | Out-Null
        }
        Write-Host "�������������� ���������� ������ �������� ��������." -ForegroundColor Green
    } else {
        # ��������� ��������������, ���� ��� ��������
        if ($sys.AutomaticManagedPagefile) {
            $sys.AutomaticManagedPagefile = $false
            Set-CimInstance -InputObject $sys | Out-Null
        }

        # �������� ������� ��������� ������ ��������
        $pfSettings = Get-CimInstance -ClassName Win32_PageFileSetting

        if ($Mode -eq "None") {
            if ($pfSettings) {
                $pfSettings | Remove-CimInstance
            }
            Write-Host "���� �������� ��������� ��������." -ForegroundColor Yellow
        } else {
            $sz = [int]$Mode
            
            if (-not $pfSettings) {
                # ������� ����� ���� �������� �� ��������� �����, ���� �������� �� ���� �����
                New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                    Name = $pagefilePath
                    InitialSize = $sz
                    MaximumSize = $sz
                } | Out-Null
            } else {
                # ����������� ������ ���� ���� �� ��������� �����, 
                # � ����� �� ������ ������ ������� �� ��������� ������������ �����
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
                
                # ���� �� ��������� ����� ����� �� ����, ������� ���
                if (-not $systemDriveFound) {
                    New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                        Name = $pagefilePath
                        InitialSize = $sz
                        MaximumSize = $sz
                    } | Out-Null
                }
            }
            Write-Host "���� �������� ������ ������������: $sz MB �� ����� $systemDrive." -ForegroundColor Green
        }
    }
} catch {
    Write-Host "������ ��������� ����� ��������: $($_.Exception.Message)" -ForegroundColor Red
}