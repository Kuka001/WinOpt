@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%=== Отключение телеметрии ===%X%
echo.

echo %Y%[1/5] Политики сбора данных...%X%
for %%V in (
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,AllowTelemetry,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,MaxTelemetryAllowed,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,DoNotShowFeedbackNotifications,1"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,LimitDiagnosticLogCollection,1"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,DisableOneSettingsDownloads,1"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection,AllowDeviceNameInTelemetry,0"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection,AllowTelemetry,0"
    "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting,Disabled,1"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\System,PublishUserActivities,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\System,UploadUserActivities,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo,DisabledByGroupPolicy,1"
    "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows,CEIPEnable,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat,AITEnable,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat,DisableInventory,1"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy,TailoredExperiencesWithDiagnosticDataEnabled,0"
    "HKCU\SOFTWARE\Microsoft\Siuf\Rules,NumberOfSIUFInPeriod,0"
    "HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy,HasAccepted,0"
    "HKCU\Control Panel\International\User Profile,HttpAcceptLanguageOptOut,1"
    "HKCU\Software\Microsoft\InputPersonalization,RestrictImplicitInkCollection,1"
    "HKCU\Software\Microsoft\InputPersonalization,RestrictImplicitTextCollection,1"
    "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore,HarvestContacts,0"
    "HKCU\Software\Microsoft\Personalization\Settings,AcceptedPrivacyPolicy,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search,DeviceHistoryEnabled,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-338389Enabled,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-353694Enabled,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-353696Enabled,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SilentInstalledAppsEnabled,0"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SystemPaneSuggestionsEnabled,0"
) do (
    for /f "tokens=1,2,3 delims=," %%a in ("%%~V") do reg add "%%a" /v "%%b" /t REG_DWORD /d %%c /f >nul 2>&1
)

echo %Y%[2/5] Отключение служб телеметрии...%X%
for %%S in (DiagTrack dmwappushservice WerSvc) do (
    net stop "%%S" /y >nul 2>&1
    sc config "%%S" start= disabled >nul 2>&1
)

echo %Y%[3/5] Блокировка задач планировщика...%X%
for %%T in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Device Information\Device"
    "\Microsoft\Windows\Device Information\Device User"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
) do (schtasks /change /tn "%%~T" /disable >nul 2>&1)

echo %Y%[4/5] Отключение ИИ (Recall, Copilot)...%X%
:: Отключение Recall и анализа данных экрана (на уровне системы и пользователя)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecall" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1

:: Отключение Copilot и применение системной политики удаления
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "RemoveMicrosoftCopilotApp" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "RemoveMicrosoftCopilotApp" /t REG_DWORD /d 1 /f >nul 2>&1

:: Полное удаление пакетов Copilot для всех пользователей
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers *Copilot* | Remove-AppxPackage -AllUsers" >nul 2>&1

echo %Y%[5/5] Блокировка серверов телеметрии в hosts...%X%
set "hp=%SystemRoot%\System32\drivers\etc\hosts"
attrib -r "%hp%" >nul 2>&1

:: Проверяем наличие записей, чтобы избежать дублирования пустых строк при повторном запуске
findstr /I /C:"v10.events.data.microsoft.com" "%hp%" >nul 2>&1
if errorlevel 1 (
    >>"%hp%" echo.
    >>"%hp%" echo # [Telemetry Block]
    for %%D in (
        v10.events.data.microsoft.com v20.events.data.microsoft.com self.events.data.microsoft.com
        settings-win.data.microsoft.com watson.telemetry.microsoft.com telemetry.microsoft.com
    ) do (
        echo 0.0.0.0 %%D>>"%hp%"
    )
)
attrib +r "%hp%" >nul 2>&1

echo.
echo %G%Телеметрия отключена!%X%
echo %R%Рекомендуется перезагрузка.%X%
echo. & pause
exit /b