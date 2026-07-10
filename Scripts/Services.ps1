# =====================================================================
# Интерактивное управление службами Windows — TUI с курсорной навигацией
# =====================================================================

# --- Проверка прав администратора ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Требуются права Администратора!" -ForegroundColor Red
    exit 1
}

# --- Загрузка списков служб ---
. "$PSScriptRoot\ServiceLists.ps1"

# --- ANSI escape ---
$ESC = [char]27
$RESET  = "$ESC[0m"
$RED    = "$ESC[31m"
$GREEN  = "$ESC[32m"
$YELLOW = "$ESC[33m"
$GRAY   = "$ESC[90m"
$WHITE  = "$ESC[97m"
$INVERSE = "$ESC[7m"
$BOLD   = "$ESC[1m"
$DGREEN = "$ESC[32m"
$DYELLOW = "$ESC[33m"
$DRED   = "$ESC[31m"

# --- Функция проверки совпадения с wildcard-списком ---
function Test-InList {
    param([string]$Name, [string[]]$List)
    foreach ($pattern in $List) {
        if ($Name -like $pattern) { return $true }
    }
    return $false
}

# --- Функция извлечения базового имени per-user службы ---
function Get-BaseServiceName {
    param([string]$Name)
    if ($Name -match '^(.+)_[0-9a-f]{4,}$') {
        return $Matches[1]
    }
    return $null
}

# --- Сбор данных о службах ---
function Collect-Services {
    $services = [System.Collections.Generic.List[hashtable]]::new()

    Get-Service | Where-Object { $_.ServiceType -match 'Win32' } | ForEach-Object {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($_.Name)"
        $startVal = 3
        if (Test-Path $regPath) {
            $sv = (Get-ItemProperty $regPath -Name Start -EA SilentlyContinue).Start
            if ($null -ne $sv) { $startVal = $sv }
        }

        $category = 'Unknown'
        if (Test-InList $_.Name $CriticalServices) {
            $category = 'Critical'
        } elseif (Test-InList $_.Name $RecommendedServices) {
            $category = 'Recommended'
        }

        $services.Add(@{
            Name        = $_.Name
            DisplayName = $_.DisplayName
            Status      = $_.Status.ToString()
            StartType   = $startVal
            Category    = $category
            Action      = 'None'
            IsGroup     = $false
            IsExpanded  = $false
            Children    = $null
            BaseName    = $null
        })
    }

    return $services
}

# --- Группировка per-user служб ---
function Group-PerUserServices {
    param([System.Collections.Generic.List[hashtable]]$Services)

    $grouped = [System.Collections.Generic.List[hashtable]]::new()
    $perUserGroups = @{}

    foreach ($svc in $Services) {
        $baseName = Get-BaseServiceName $svc.Name
        if ($null -ne $baseName) {
            if (-not $perUserGroups.ContainsKey($baseName)) {
                $perUserGroups[$baseName] = [System.Collections.Generic.List[hashtable]]::new()
            }
            $perUserGroups[$baseName].Add($svc)
        } else {
            $grouped.Add($svc)
        }
    }

    foreach ($base in $perUserGroups.Keys) {
        $children = $perUserGroups[$base]
        $firstChild = $children[0]

        $group = @{
            Name        = $base
            DisplayName = "$($firstChild.DisplayName -replace '_[0-9a-f]{4,}$','')"
            Status      = ($children | Where-Object { $_.Status -eq 'Running' } | Measure-Object).Count.ToString() + "/" + $children.Count.ToString() + " работают"
            StartType   = $firstChild.StartType
            Category    = $firstChild.Category
            Action      = 'None'
            IsGroup     = $true
            IsExpanded  = $false
            Children    = $children
            BaseName    = $base
        }
        $grouped.Add($group)
    }

    return $grouped
}

# --- Построение отображаемого списка для текущей категории ---
function Build-DisplayList {
    param([System.Collections.Generic.List[hashtable]]$Services, [string]$Category)

    $list = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($svc in $Services) {
        if ($svc.Category -ne $Category) { continue }
        $list.Add($svc)
        if ($svc.IsGroup -and $svc.IsExpanded -and $null -ne $svc.Children) {
            foreach ($child in $svc.Children) {
                $childCopy = $child.Clone()
                $childCopy['IsChild'] = $true
                $list.Add($childCopy)
            }
        }
    }
    return $list
}

# --- Форматирование состояния службы ---
function Format-Status {
    param([hashtable]$Svc)
    if ($Svc.IsGroup) { return $Svc.Status }
    $status = $Svc.Status
    $startLabel = switch ($Svc.StartType) {
        2 { $DGREEN + "Авто" + $RESET }
        3 { $DYELLOW + "Ручн" + $RESET }
        4 { $DRED + "Откл" + $RESET }
        default { "" }
    }
    $statusText = switch ($status) {
        'Running' { "Работает" }
        'Stopped' { "Остановлена" }
        default   { $status }
    }
    if ($startLabel) { return "$statusText ($startLabel)" }
    return $statusText
}

# --- Форматирование действия ---
function Format-Action {
    param([hashtable]$Svc)
    switch ($Svc.Action) {
        'None'    { return $GRAY + "(без изменений)" + $RESET }
        'Disable' { return $RED + "-> Отключить" + $RESET }
        'Manual'  { return $YELLOW + "-> Вручную" + $RESET }
        'Auto'    { return $GREEN + "-> Авто" + $RESET }
    }
    return ""
}

# --- Цвет состояния ---
function Get-StatusColor {
    param([hashtable]$Svc)
    if ($Svc.IsGroup) { return $WHITE }
    switch ($Svc.Status) {
        'Running' { return $GREEN }
        'Stopped' { return $GRAY }
        default   { return $GRAY }
    }
}

# --- Рендеринг экрана ---
function Render-Screen {
    param(
        [System.Collections.Generic.List[hashtable]]$DisplayList,
        [int]$CursorPos,
        [int]$ScrollOffset,
        [string]$Category,
        [int]$PageSize,
        [int]$TotalRecommended,
        [int]$TotalUnknown,
        [int]$TotalCritical,
        [string]$Message
    )

    $lines = [System.Collections.Generic.List[string]]::new(64)
    $width = [Console]::WindowWidth

    # Заголовок
    $lines.Add($BOLD + $GREEN + "=== Управление службами ===" + $RESET)
    $lines.Add("")

    # Подсказки
    $hints = '[Tab] Категория ' + '| [Space] Действие ' + '| [S] Стоп ' + '| [R] Запуск ' + '| [F5] Откл.все ' + '| [F8] Применить ' + '| [Esc] Выход'
    $lines.Add($GRAY + $hints + $RESET)
    $lines.Add("")

    # Вкладка категории
    $catTitle = switch ($Category) {
        'Recommended' { $GREEN + 'Рекомендованы к отключению (' + $TotalRecommended + ')' + $RESET }
        'Unknown'     { $YELLOW + 'Неизвестные (' + $TotalUnknown + ')' + $RESET }
        'Critical'    { $RED + 'Критические: НЕ ТРОГАТЬ! (' + $TotalCritical + ')' + $RESET }
        'Fixes'       { $GREEN + 'Исправления (восстановление функций)' + $RESET }
    }
    $border = [string][char]0x2500
    $lines.Add($border + $border + ' ' + $catTitle + ' ' + ($border * 20))

    # Заголовок таблицы
    $nameCol = 'Служба'.PadRight(38)
    $statusCol = 'Состояние'.PadRight(20)
    $actionCol = 'Действие'
    $lines.Add($GRAY + '  #  ' + $nameCol + ' ' + $statusCol + ' ' + $actionCol + $RESET)
    $lines.Add($GRAY + ($border * 80) + $RESET)

    # Строки
    $visibleEnd = [Math]::Min($ScrollOffset + $PageSize, $DisplayList.Count)
    for ($i = $ScrollOffset; $i -lt $visibleEnd; $i++) {
        $svc = $DisplayList[$i]
        $isCurrent = ($i -eq $CursorPos)
        $num = ($i + 1).ToString().PadLeft(3)

        # Имя с отступом для дочерних
        $prefix = ""
        if ($svc.ContainsKey('IsChild') -and $svc['IsChild']) {
            $prefix = "  "
        }

        $displayName = $svc.Name
        if ($svc.IsGroup) {
            if ($svc.IsExpanded) { $arrow = "v" } else { $arrow = ">" }
            $displayName = $arrow + " " + $svc.Name + " [per-user]"
        }
        $displayName = $prefix + $displayName
        if ($displayName.Length -gt 38) { $displayName = $displayName.Substring(0, 35) + "..." }
        $displayName = $displayName.PadRight(38)

        $statusText = (Format-Status $svc)
        $statusVisible = $statusText -replace "$ESC\[[0-9;]*m", ''
        $statusPad = 20 - $statusVisible.Length
        if ($statusPad -gt 0) { $statusText = $statusText + (' ' * $statusPad) }
        $statusColor = Get-StatusColor $svc

        $actionText = Format-Action $svc

        if ($isCurrent) { $pointer = $INVERSE; $endPointer = $RESET } else { $pointer = ""; $endPointer = "" }
        if ($isCurrent) { $marker = [string][char]0x25BA } else { $marker = " " }

        $line = $pointer + $marker + $num + ". " + $displayName + " " + $statusText + $RESET + $pointer + " " + $actionText + $endPointer
        $lines.Add($line)
    }

    # Заполнение пустых строк
    $emptyLines = $PageSize - ($visibleEnd - $ScrollOffset)
    for ($j = 0; $j -lt $emptyLines; $j++) {
        $lines.Add("")
    }

    # Нижняя граница
    $lines.Add($GRAY + ($border * 80) + $RESET)

    # Статусная строка
    $totalPages = [Math]::Ceiling($DisplayList.Count / [Math]::Max($PageSize, 1))
    $currentPage = [Math]::Floor($ScrollOffset / [Math]::Max($PageSize, 1)) + 1
    if ($totalPages -eq 0) { $totalPages = 1; $currentPage = 1 }
    $statusLine = $GRAY + 'Стр. ' + $currentPage + '/' + $totalPages + ' | Всего: ' + $DisplayList.Count + ' | ^v навигация  PgUp/PgDn листание' + $RESET
    $lines.Add($statusLine)

    # Сообщение (если есть)
    if ($Message) {
        $lines.Add("")
        $lines.Add($Message)
    }

    # Вывод — каждую строку дополняем пробелами до ширины экрана чтобы затереть остатки
    [Console]::SetCursorPosition(0, 0)
    $output = [System.Text.StringBuilder]::new()
    foreach ($l in $lines) {
        $visible = $l -replace "$ESC\[[0-9;]*m", ''
        $pad = $width - $visible.Length
        if ($pad -gt 0) {
            [void]$output.AppendLine($l + (' ' * $pad))
        } else {
            [void]$output.AppendLine($l)
        }
    }
    [void]$output.Append("$ESC[J")
    [Console]::Write($output.ToString())
}

# --- Рендеринг вкладки "Исправления" ---
function Render-Fixes {
    param(
        [int]$CursorPos,
        [int]$PageSize,
        [string]$Message
    )

    $lines = [System.Collections.Generic.List[string]]::new(64)
    $width = [Console]::WindowWidth
    $border = [string][char]0x2500

    $lines.Add($BOLD + $GREEN + "=== Управление службами ===" + $RESET)
    $lines.Add("")
    $lines.Add($GRAY + '[Tab] Категория ' + '| [Enter] Восстановить ' + '| [Esc] Выход' + $RESET)
    $lines.Add("")
    $lines.Add($border + $border + ' ' + $GREEN + 'Исправления (восстановление функций)' + $RESET + ' ' + ($border * 20))
    $lines.Add("")
    $lines.Add($GRAY + '  Выберите что восстановить — службы будут включены после перезагрузки' + $RESET)
    $lines.Add("")

    for ($i = 0; $i -lt $FixPacks.Count; $i++) {
        $pack = $FixPacks[$i]
        $isCurrent = ($i -eq $CursorPos)

        if ($isCurrent) { $pointer = $INVERSE; $endPointer = $RESET; $marker = [string][char]0x25BA }
        else { $pointer = ""; $endPointer = ""; $marker = " " }

        $num = ($i + 1).ToString().PadLeft(2)
        $packName = $pack.Name.PadRight(20)

        # Проверяем текущее состояние служб набора
        $allDisabled = $true
        foreach ($svcName in $pack.Services) {
            $rp = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
            if (Test-Path $rp) {
                $st = (Get-ItemProperty $rp -Name Start -EA SilentlyContinue).Start
                if ($st -ne 4) { $allDisabled = $false; break }
            }
        }

        if ($allDisabled) {
            $status = $RED + '[ОТКЛЮЧЕНО]' + $RESET
        } else {
            $status = $GREEN + '[OK]' + $RESET
        }

        $line = $pointer + $marker + $num + '. ' + $packName + ' ' + $status + '  ' + $GRAY + $pack.Description + $RESET + $endPointer
        $lines.Add($line)
    }

    # Заполнение
    $emptyLines = $PageSize - $FixPacks.Count
    for ($j = 0; $j -lt $emptyLines; $j++) { $lines.Add("") }

    $lines.Add($GRAY + ($border * 80) + $RESET)
    $lines.Add($GRAY + 'Enter = восстановить выбранный набор (тип запуска Авто)' + $RESET)

    if ($Message) {
        $lines.Add("")
        $lines.Add($Message)
    }

    [Console]::SetCursorPosition(0, 0)
    $output = [System.Text.StringBuilder]::new()
    foreach ($l in $lines) {
        $visible = $l -replace "$ESC\[[0-9;]*m", ''
        $pad = $width - $visible.Length
        if ($pad -gt 0) { [void]$output.AppendLine($l + (' ' * $pad)) }
        else { [void]$output.AppendLine($l) }
    }
    [void]$output.Append("$ESC[J")
    [Console]::Write($output.ToString())
}

# --- Применение изменений ---
function Apply-Changes {
    param([System.Collections.Generic.List[hashtable]]$AllServices)

    $pending = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($svc in $AllServices) {
        if ($svc.Action -ne 'None') {
            if ($svc.IsGroup -and $null -ne $svc.Children) {
                foreach ($child in $svc.Children) {
                    if ($child.Action -eq 'None') { $child.Action = $svc.Action }
                    $pending.Add($child)
                }
            } else {
                $pending.Add($svc)
            }
        }
    }

    if ($pending.Count -eq 0) { return $null }

    # Экран подтверждения
    [Console]::Clear()
    Write-Host ($BOLD + $YELLOW + "=== Подтверждение изменений ===" + $RESET) -NoNewline
    Write-Host ""
    Write-Host ""

    $disCount = @($pending | Where-Object { $_.Action -eq 'Disable' }).Count
    $manCount = @($pending | Where-Object { $_.Action -eq 'Manual' }).Count
    $autoCount = @($pending | Where-Object { $_.Action -eq 'Auto' }).Count

    Write-Host "  Отключить: $disCount" -ForegroundColor Red
    Write-Host "  Вручную:   $manCount" -ForegroundColor Yellow
    Write-Host "  Авто:      $autoCount" -ForegroundColor Green
    Write-Host ""
    Write-Host "Список:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($svc in $pending) {
        $actionLabel = switch ($svc.Action) {
            'Disable' { "[ОТКЛ]" }
            'Manual'  { "[РУЧН]" }
            'Auto'    { "[АВТО]" }
        }
        Write-Host "  $actionLabel $($svc.Name)"
    }

    Write-Host ""
    Write-Host ($YELLOW + "Применить? (Y/N)" + $RESET) -NoNewline
    Write-Host " " -NoNewline

    $confirm = [Console]::ReadKey($true)
    if ($confirm.Key -ne 'Y') {
        return "Отменено."
    }

    Write-Host ""
    Write-Host ""

    $ok = 0; $fail = 0
    foreach ($svc in $pending) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
        $targetStart = switch ($svc.Action) {
            'Disable' { 4 }
            'Manual'  { 3 }
            'Auto'    { 2 }
        }

        if (-not (Test-Path $regPath)) {
            Write-Host "  [-] $($svc.Name) — не найден в реестре" -ForegroundColor Gray
            $fail++
            continue
        }

        try {
            Set-ItemProperty $regPath 'Start' $targetStart -Force -ErrorAction Stop
        } catch {
            try {
                $null = sc.exe config $svc.Name start= disabled 2>&1
                Set-ItemProperty $regPath 'Start' $targetStart -Force -EA SilentlyContinue
            } catch {}
        }

        $verifyStart = (Get-ItemProperty $regPath -Name Start -EA SilentlyContinue).Start
        if ($null -ne $verifyStart -and $verifyStart -eq $targetStart) {
            if ($svc.Action -eq 'Disable' -and $svc.Status -eq 'Running') {
                try { Stop-Service $svc.Name -Force -ErrorAction Stop } catch {
                    try {
                        $proc = Get-WmiObject Win32_Service -Filter "Name='$($svc.Name)'" -EA Stop
                        if ($proc.ProcessId -gt 0) { Stop-Process -Id $proc.ProcessId -Force -EA SilentlyContinue }
                    } catch {}
                }
            }
            Write-Host "  [+] $($svc.Name)" -ForegroundColor Green
            $svc.StartType = $targetStart
            $svc.Action = 'None'
            $ok++
        } else {
            Write-Host "  [-] $($svc.Name) — ошибка записи (будет применено после перезагрузки)" -ForegroundColor Yellow
            $fail++
        }
    }

    Write-Host ""
    Write-Host "Результат: успешно=$ok | ошибок=$fail" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ($YELLOW + "Требуется перезагрузка для полного применения." + $RESET)
    Write-Host ""
    Write-Host "Нажмите любую клавишу..." -ForegroundColor Gray
    [void][Console]::ReadKey($true)
    return $null
}

# === ГЛАВНЫЙ ЦИКЛ ===

# Скрыть курсор
[Console]::CursorVisible = $false

try {
    # Сбор и группировка
    $allServices = Collect-Services
    $allServices = Group-PerUserServices $allServices

    # Сортировка: сначала Running, потом Авто(2), Ручн(3), Откл(4), внутри по имени
    $sortedArr = @($allServices | Sort-Object {
        $priority = switch ($_.Status) { 'Running' { 0 } default { 1 } }
        if ($priority -eq 1) {
            $priority = switch ($_.StartType) { 2 { 1 } 3 { 2 } 4 { 3 } default { 2 } }
        }
        $priority
    }, { $_.Name })
    $allServices = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($item in $sortedArr) { $allServices.Add($item) }

    # Состояние TUI
    $categories = @('Recommended', 'Unknown', 'Critical', 'Fixes')
    $catIndex = 0
    $cursorPos = 0
    $scrollOffset = 0
    $message = ""
    $running = $true

    while ($running) {
        $currentCat = $categories[$catIndex]

        $pageSize = [Console]::WindowHeight - 12
        if ($pageSize -lt 5) { $pageSize = 5 }

        # --- Вкладка "Исправления" — отдельная логика ---
        if ($currentCat -eq 'Fixes') {
            if ($cursorPos -ge $FixPacks.Count) { $cursorPos = $FixPacks.Count - 1 }
            if ($cursorPos -lt 0) { $cursorPos = 0 }
            Render-Fixes $cursorPos $pageSize $message
            $message = ""
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                'UpArrow'   { $cursorPos--; if ($cursorPos -lt 0) { $cursorPos = 0 } }
                'DownArrow' { $cursorPos++; if ($cursorPos -ge $FixPacks.Count) { $cursorPos = $FixPacks.Count - 1 } }
                'Tab'       { $catIndex = ($catIndex + 1) % 4; $cursorPos = 0; $scrollOffset = 0 }
                'Escape'    { $running = $false }
                'Enter' {
                    $pack = $FixPacks[$cursorPos]
                    $okCount = 0; $failCount = 0
                    foreach ($svcName in $pack.Services) {
                        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
                        if (Test-Path $regPath) {
                            try {
                                Set-ItemProperty $regPath 'Start' $pack.StartType -Force -ErrorAction Stop
                                $okCount++
                            } catch { $failCount++ }
                        } else { $failCount++ }
                    }
                    $message = $GREEN + 'Восстановлено: ' + $pack.Name + ' (' + $okCount + ' служб). Перезагрузите ПК.' + $RESET
                    # Обновим данные служб
                    $raw = Collect-Services
                    $raw = Group-PerUserServices $raw
                    $sortedArr = @($raw | Sort-Object {
                        $p = switch ($_.Status) { 'Running' { 0 } default { 1 } }
                        if ($p -eq 1) { $p = switch ($_.StartType) { 2 { 1 } 3 { 2 } 4 { 3 } default { 2 } } }
                        $p
                    }, { $_.Name })
                    $allServices = [System.Collections.Generic.List[hashtable]]::new()
                    foreach ($item in $sortedArr) { $allServices.Add($item) }
                }
            }
            continue
        }

        # --- Обычные категории ---
        $displayList = Build-DisplayList $allServices $currentCat

        # Подсчёт для заголовков
        $totalRec = ($allServices | Where-Object { $_.Category -eq 'Recommended' }).Count
        $totalUnk = ($allServices | Where-Object { $_.Category -eq 'Unknown' }).Count
        $totalCrt = ($allServices | Where-Object { $_.Category -eq 'Critical' }).Count

        # Ограничения курсора
        if ($displayList.Count -eq 0) { $cursorPos = 0; $scrollOffset = 0 }
        else {
            if ($cursorPos -ge $displayList.Count) { $cursorPos = $displayList.Count - 1 }
            if ($cursorPos -lt 0) { $cursorPos = 0 }
            if ($cursorPos -lt $scrollOffset) { $scrollOffset = $cursorPos }
            if ($cursorPos -ge ($scrollOffset + $pageSize)) { $scrollOffset = $cursorPos - $pageSize + 1 }
        }

        Render-Screen $displayList $cursorPos $scrollOffset $currentCat $pageSize $totalRec $totalUnk $totalCrt $message
        $message = ""

        # Ввод
        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow' {
                $cursorPos--
                if ($cursorPos -lt 0) { $cursorPos = 0 }
            }
            'DownArrow' {
                $cursorPos++
                if ($cursorPos -ge $displayList.Count) { $cursorPos = $displayList.Count - 1 }
                if ($cursorPos -lt 0) { $cursorPos = 0 }
            }
            'PageUp' {
                $cursorPos -= $pageSize
                $scrollOffset -= $pageSize
                if ($cursorPos -lt 0) { $cursorPos = 0 }
                if ($scrollOffset -lt 0) { $scrollOffset = 0 }
            }
            'PageDown' {
                $cursorPos += $pageSize
                $scrollOffset += $pageSize
                if ($cursorPos -ge $displayList.Count) { $cursorPos = $displayList.Count - 1 }
                if ($cursorPos -lt 0) { $cursorPos = 0 }
                $maxScroll = [Math]::Max(0, $displayList.Count - $pageSize)
                if ($scrollOffset -gt $maxScroll) { $scrollOffset = $maxScroll }
            }
            'Home' {
                $cursorPos = 0
                $scrollOffset = 0
            }
            'End' {
                $cursorPos = $displayList.Count - 1
                if ($cursorPos -lt 0) { $cursorPos = 0 }
                $scrollOffset = [Math]::Max(0, $displayList.Count - $pageSize)
            }
            'Tab' {
                $catIndex = ($catIndex + 1) % 4
                $cursorPos = 0
                $scrollOffset = 0
            }
            'Spacebar' {
                if ($currentCat -eq 'Critical') {
                    $message = $RED + "Критические службы нельзя изменять!" + $RESET
                } elseif ($displayList.Count -gt 0) {
                    $svc = $displayList[$cursorPos]
                    switch ($svc.Action) {
                        'None'    { $svc.Action = 'Disable' }
                        'Disable' { $svc.Action = 'Manual' }
                        'Manual'  { $svc.Action = 'Auto' }
                        'Auto'    { $svc.Action = 'None' }
                    }
                }
            }
            'Enter' {
                if ($displayList.Count -gt 0) {
                    $svc = $displayList[$cursorPos]
                    if ($svc.IsGroup) {
                        $svc.IsExpanded = -not $svc.IsExpanded
                    } elseif ($currentCat -ne 'Critical') {
                        switch ($svc.Action) {
                            'None'    { $svc.Action = 'Disable' }
                            'Disable' { $svc.Action = 'Manual' }
                            'Manual'  { $svc.Action = 'Auto' }
                            'Auto'    { $svc.Action = 'None' }
                        }
                    }
                }
            }
            'RightArrow' {
                if ($displayList.Count -gt 0) {
                    $svc = $displayList[$cursorPos]
                    if ($svc.IsGroup -and -not $svc.IsExpanded) {
                        $svc.IsExpanded = $true
                    }
                }
            }
            'LeftArrow' {
                if ($displayList.Count -gt 0) {
                    $svc = $displayList[$cursorPos]
                    if ($svc.IsGroup -and $svc.IsExpanded) {
                        $svc.IsExpanded = $false
                    }
                }
            }
            'S' {
                if ($displayList.Count -gt 0 -and $currentCat -ne 'Critical') {
                    $svc = $displayList[$cursorPos]
                    if ($svc.IsGroup) {
                        $message = $YELLOW + "Для группы используйте раскрытие (Enter) и выберите конкретную службу" + $RESET
                    } elseif ($svc.Status -eq 'Running') {
                        $stopped = $false
                        try {
                            Stop-Service $svc.Name -Force -ErrorAction Stop
                            $stopped = $true
                        } catch {
                            try {
                                $proc = Get-WmiObject Win32_Service -Filter "Name='$($svc.Name)'" -EA Stop
                                if ($proc.ProcessId -gt 0) {
                                    Stop-Process -Id $proc.ProcessId -Force -EA Stop
                                    $stopped = $true
                                }
                            } catch {}
                        }
                        if ($stopped) {
                            $svc.Status = 'Stopped'
                            $message = $GREEN + "Остановлена: " + $svc.Name + $RESET
                        } else {
                            $message = $RED + "Ошибка остановки: " + $svc.Name + " (будет отключена после перезагрузки)" + $RESET
                        }
                    } else {
                        $message = $GRAY + "Служба уже остановлена" + $RESET
                    }
                } elseif ($currentCat -eq 'Critical') {
                    $message = $RED + "Критические службы нельзя изменять!" + $RESET
                }
            }
            'R' {
                if ($displayList.Count -gt 0 -and $currentCat -ne 'Critical') {
                    $svc = $displayList[$cursorPos]
                    if ($svc.IsGroup) {
                        $message = $YELLOW + "Для группы используйте раскрытие (Enter) и выберите конкретную службу" + $RESET
                    } elseif ($svc.Status -ne 'Running') {
                        try {
                            Start-Service $svc.Name -ErrorAction Stop
                            $svc.Status = 'Running'
                            $message = $GREEN + "Запущена: " + $svc.Name + $RESET
                        } catch {
                            $message = $RED + "Ошибка запуска: " + $svc.Name + " - " + $_.Exception.Message + $RESET
                        }
                    } else {
                        $message = $GRAY + "Служба уже работает" + $RESET
                    }
                } elseif ($currentCat -eq 'Critical') {
                    $message = $RED + "Критические службы нельзя изменять!" + $RESET
                }
            }
            'Escape' {
                $hasPending = $false
                foreach ($s in $allServices) {
                    if ($s.Action -ne 'None') { $hasPending = $true; break }
                }
                if ($hasPending) {
                    $message = $YELLOW + "Есть неприменённые изменения! [F8] применить или [Esc] ещё раз для выхода" + $RESET
                    Render-Screen $displayList $cursorPos $scrollOffset $currentCat $pageSize $totalRec $totalUnk $totalCrt $message
                    $confirm = [Console]::ReadKey($true)
                    if ($confirm.Key -eq 'Escape') { $running = $false }
                } else {
                    $running = $false
                }
            }
            'F5' {
                $count = 0
                foreach ($s in $allServices) {
                    if ($s.Category -eq 'Recommended' -and $s.StartType -ne 4) {
                        $s.Action = 'Disable'
                        $count++
                        if ($s.IsGroup -and $null -ne $s.Children) {
                            foreach ($child in $s.Children) {
                                if ($child.StartType -ne 4) { $child.Action = 'Disable' }
                            }
                        }
                    }
                }
                $message = $GREEN + "Помечено к отключению: $count служб. Нажмите [F8] для применения." + $RESET
            }
            'F8' {
                $result = Apply-Changes $allServices
                if ($result) { $message = $result }
                # Перечитать данные после применения
                $raw = Collect-Services
                $raw = Group-PerUserServices $raw
                $sortedArr2 = @($raw | Sort-Object {
                    $p = switch ($_.Status) { 'Running' { 0 } default { 1 } }
                    if ($p -eq 1) { $p = switch ($_.StartType) { 2 { 1 } 3 { 2 } 4 { 3 } default { 2 } } }
                    $p
                }, { $_.Name })
                $allServices = [System.Collections.Generic.List[hashtable]]::new()
                foreach ($item in $sortedArr2) { $allServices.Add($item) }
            }
        }
    }
} finally {
    # Восстановить курсор и очистить
    [Console]::CursorVisible = $true
    [Console]::Clear()
}
