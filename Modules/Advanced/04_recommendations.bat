@echo off
setlocal EnableDelayedExpansion
call "%~dp0..\..\Core\init.bat"

cls
echo %Y%=== Отключение рекомендаций и рекламы ===%X%
echo.

for %%V in (
    "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo,Enabled,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo,DisabledByGroupPolicy,1"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy,TailoredExperiencesWithDiagnosticDataEnabled,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent,DisableTailoredExperiencesWithDiagnosticData,1"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer,HideRecentlyAddedApps,1"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced,Start_IrisRecommendations,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SystemSuggestedAppsFolderLinkEnabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-338388Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-338389Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SilentInstalledAppsEnabled,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search,EnableSearchHighlights,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,RotatingLockScreenEnabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-338387Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement,ScoobeSystemSettingEnabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-310093Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-338393Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-353694Enabled,0"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager,SubscribedContent-353696Enabled,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent,DisableConsumerAccountStateContent,1"
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced,ShowSyncProviderNotifications,0"
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat,ChatIcon,3"
) do (
    for /f "tokens=1-3 delims=," %%a in ("%%~V") do reg add "%%a" /v "%%b" /t REG_DWORD /d %%c /f >nul 2>&1
)

call "%~dp0..\..\Core\helpers.bat" restart_explorer
echo.
echo %G%Реклама и рекомендации отключены!%X%
echo. & pause
exit /b