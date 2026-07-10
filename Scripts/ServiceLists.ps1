# --- Рекомендованные к отключению ---
$RecommendedServices = @(
    # Телеметрия / Диагностика
    'DiagTrack'
    'diagsvc'
    'WdiServiceHost'
    'WdiSystemHost'
    'InventorySvc'
    'WerSvc'
    'wercplsupport'
    'dmwappushservice'
    'PcaSvc'
    'SysMain'
    'TrkWks'
    'TroubleshootingSvc'
    'pla'
    'whesvc'

    # Windows Update
    'DoSvc'
    'UsoSvc'
    'PushToInstall'
    'InstallService'

    # Xbox / Игры
    'XblAuthManager'
    'XblGameSave'
    'XboxGipSvc'
    'XboxNetApiSvc'
    'BcastDVRUserService'
    'GameInputSvc'

    # Печать
    'Spooler'
    'PrintNotify'
    'PrintWorkflowUserSvc'
    'WiaRpc'
    'PrintDeviceConfigurationService'
    'PrintScanBrokerService'

    # Bluetooth
    'bthserv'
    'BTAGService'
    'BthAvctpSvc'

    # Сеть / Общий доступ
    'LanmanServer'
    'lmhosts'
    'CDPSvc'
    'SharedAccess'
    'SSDPSRV'
    'upnphost'
    'WFDSConMgrSvc'
    'fdPHost'
    'FDResPub'
    'lltdsvc'
    'icssvc'
    'NcdAutoSetup'
    'NetTcpPortSharing'
    'RemoteRegistry'
    'Netlogon'
    'ALG'
    'IKEEXT'
    'PolicyAgent'
    'NcaSvc'
    'wcncsvc'
    'RasAuto'
    'RemoteAccess'
    'WebClient'
    'WinRM'
    'hns'

    # VPN
    'RasMan'
    'SstpSvc'

    # Hyper-V / Виртуализация
    'HvHost'
    'vid'
    'vmcompute'
    'vmicguestinterface'
    'vmicheartbeat'
    'vmickvpexchange'
    'vmicrdv'
    'vmicshutdown'
    'vmictimesync'
    'vmicvmsession'
    'vmicvss'

    # Биометрия / Аутентификация
    'WbioSrvc'
    'NgcCtnrSvc'
    'NaturalAuthentication'
    'SEMgrSvc'

    # Камера
    'FrameServer'
    'FrameServerMonitor'

    # Nvidia / AMD / ASUS / Вендорное
    'NVDisplay.ContainerLocalSystem'
    'nvagent'
    'FMAPOService'
    'DolbyDAXAPI'
    'RtkAudioUniversalService'
    'AMD Crash Defender Service'
    'AMD External Events Utility'
    'amdfendr'
    'ArmouryCrateControlInterface'
    'AsusAppService'
    'ASUSOptimization'
    'ASUSSoftwareManager'
    'ASUSSwitch'
    'ASUSSystemAnalysis'
    'ASUSSystemDiagnosis'
    'MicrosoftCopilotElevationService'
    'GoogleUpdaterInternalService*'
    'GoogleUpdaterService*'
    'GoogleChromeElevationService'
    'edgeupdate'
    'edgeupdatem'

    # UWP / Store
    'ClipSVC'
    'AppIDSvc'
    'ApxSvc'
    'EapHost'

    # ЭЦП / Смарт-карты
    'CertPropSvc'
    'SCardSvr'
    'ScDeviceEnum'

    # Устаревшие / Редко используемые
    'OneSyncSvc'
    'StiSvc'
    'wlidsvc'
    'MapsBroker'
    'RetailDemo'
    'SharedRealitySvc'
    'wisvc'
    'PhoneSvc'
    'Fax'
    'AutoTimeUpdater'
    'bdmshelp32'
    'ICCSVC'
    'SmsRouter'
    'WpcMonSvc'
    'AppVClient'
    'SCPolicySvc'
    'SNMPTRAP'
    'UevAgentService'
    'WMPNetworkSvc'
    'SessionEnv'
    'FvSvc'
    'WSearch'
    'DisplayEnhancementService'
    'ShellHWDetection'
    'ADPSvc'
    'AppMgmt'
    'autotimesvc'
    'AxInstSV'
    'dcsvc'
    'DmEnrollmentSvc'
    'dot3svc'
    'embeddedmode'
    'EntAppSvc'
    'cloudidsvc'
    'CscService'
    'EFS'
    'hpatchmon'
    'KtmRm'
    'MSDTC'
    'LocalKdc'
    'McpManagementService'
    'MSiSCSI'
    'PeerDistSvc'
    'perceptionsimulation'
    'QWAVE'
    'fhsvc'
    'McmSvc'
    'midisrv'
    'refsdedupsvc'
    'RpcLocator'
    'TieringEngineService'
    'WalletService'
    'Wecsvc'
    'smphost'
    'WManSvc'
    'workfolderssvc'
    'WSAIFabricSvc'
    'wuqisvc'
    'ZTHELPER'
    'AssignedAccessManagerSvc'
    'MsKeyboardFilter'
    'Sense'
    'WEPHOSTSVC'
    'wlpasvc'
    'WwanSvc'
    'BDESVC'
    'WPDBusEnum'

    # Удалённый доступ / SSH
    'ssh-agent'
    'TermService'
    'UmRdpService'
    'TapiSrv'

    # Прочее
    'IpxlatCfgSvc'
    'tzautoupdate'
    'DsmSvc'
)

# --- Критические: НЕЛЬЗЯ отключать ---
$CriticalServices = @(
    # Ядро системы
    'RpcSs'
    'RpcEptMapper'
    'DcomLaunch'
    'LSM'
    'SamSs'
    'Power'
    'BrokerInfrastructure'
    'CoreMessagingRegistrar'

    # Сеть (базовая)
    'Dnscache'
    'nsi'
    'BFE'
    'mpssvc'
    'Dhcp'
    'Wcmsvc'
    'netprofm'
    'NlaSvc'
    'NcbService'
    'WlanSvc'
    'lfsvc'
    'WinHttpAutoProxySvc'
    'RmSvc'
    'DusmSvc'
    'LanmanWorkstation'
    'iphlpsvc'
    'Netman'
    'NetSetupSvc'
    'CloudflareWARP'

    # Профили / Пользователи
    'ProfSvc'
    'UserManager'
    'gpsvc'

    # Система событий / Логи
    'EventLog'
    'EventSystem'
    'SENS'
    'SystemEventsBroker'

    # Устройства / Датчики
    'PlugPlay'
    'DeviceAssociationService'
    'DeviceInstall'
    'DevQueryBroker'
    'hidserv'
    'camsvc'
    'SensorDataService'
    'SensorService'
    'SensrSvc'
    'DPS'

    # Планировщик / Службы
    'Schedule'
    'Winmgmt'
    'msiserver'
    'COMSysApp'
    'defragsvc'

    # Криптография / Безопасность
    'CryptSvc'
    'KeyIso'
    'SecurityHealthService'
    'sppsvc'
    'NgcSvc'
    'VaultSvc'
    'seclogon'
    'WdNisSvc'
    'webthreatdefsvc'

    # Хранилище / Резервное копирование
    'StateRepository'
    'StorSvc'
    'VSS'
    'swprv'
    'vds'
    'SDRSVC'
    'wbengine'
    'svsvc'

    # UI / Отображение
    'FontCache'
    'TextInputManagementService'
    'Themes'
    'DispBrokerDesktopSvc'
    'GraphicsPerfSvc'
    'PerfHost'
    'AppReadiness'
    'LxpSvc'

    # Аудио
    'AudioSrv'
    'AudioEndpointBuilder'

    # UWP / Уведомления
    'AppXSvc'
    'WpnService'
    'WpnUserService*'
    'cbdhsvc*'


    # Прочие критические
    'Appinfo'
    'BITS'
    'TrustedInstaller'
    'wuauserv'
    'WinDefend'
    'wscsvc'
    'LicenseManager'
    'TimeBrokerSvc'
    'TokenBroker'
    'DsSvc'
    'W32Time'
    'WarpJITSvc'
    'wmiApSrv'
    'DialogBlockingService'
    'MDCoreSvc'
    'shpamsvc'
    'WaaSMedicSvc'
)

# --- Наборы для быстрого восстановления функциональности ---
$FixPacks = @(
    @{
        Name = 'Bluetooth'
        Description = 'Беспроводные наушники, колонки, клавиатуры'
        Services = @('bthserv', 'BTAGService', 'BthAvctpSvc')
        StartType = 2
    }
    @{
        Name = 'Принтер'
        Description = 'Печать, сканирование, факс'
        Services = @('Spooler', 'PrintNotify', 'PrintWorkflowUserSvc', 'WiaRpc', 'PrintDeviceConfigurationService', 'PrintScanBrokerService')
        StartType = 2
    }
    @{
        Name = 'Windows Hello / Биометрия'
        Description = 'ПИН-код, отпечаток пальца, распознавание лица'
        Services = @('WbioSrvc', 'NgcCtnrSvc', 'NaturalAuthentication')
        StartType = 2
    }
    @{
        Name = 'Xbox / GamePass'
        Description = 'Xbox приложение, GamePass, облачные сохранения'
        Services = @('XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc')
        StartType = 2
    }
    @{
        Name = 'Поиск Windows'
        Description = 'Индексация и поиск файлов'
        Services = @('WSearch')
        StartType = 2
    }
    @{
        Name = 'Сетевой доступ (SMB)'
        Description = 'Общие папки, сетевые диски'
        Services = @('LanmanWorkstation', 'LanmanServer', 'lmhosts')
        StartType = 2
    }
    @{
        Name = 'Буфер обмена (Win+V)'
        Description = 'Журнал буфера обмена, синхронизация между устройствами'
        Services = @('cbdhsvc')
        StartType = 2
    }
    @{
        Name = 'Nvidia (Панель управления)'
        Description = 'Настройки Nvidia, оверлей GeForce Experience'
        Services = @('NVDisplay.ContainerLocalSystem', 'nvagent')
        StartType = 2
    }
    @{
        Name = 'DLNA / Smart TV'
        Description = 'Трансляция на ТВ по локальной сети, UPnP'
        Services = @('SSDPSRV', 'upnphost', 'WFDSConMgrSvc', 'fdPHost', 'FDResPub')
        StartType = 2
    }
    @{
        Name = 'Веб-камера'
        Description = 'Камера для видеозвонков и записи'
        Services = @('camsvc', 'FrameServer', 'FrameServerMonitor')
        StartType = 2
    }
    @{
        Name = 'VPN / Wi-Fi с сертификатом'
        Description = 'EAP-аутентификация, корпоративный Wi-Fi'
        Services = @('EapHost')
        StartType = 2
    }
    @{
        Name = 'UWP приложения'
        Description = 'Ножницы, Калькулятор, Почта и др.'
        Services = @('AppXSvc')
        StartType = 2
    }
    @{
        Name = 'ЭЦП (NCLayer)'
        Description = 'Электронная подпись, смарт-карты'
        Services = @('CertPropSvc', 'SCardSvr', 'ScDeviceEnum')
        StartType = 2
    }
    @{
        Name = 'VPN Windows'
        Description = 'VPN-подключения средствами Windows'
        Services = @('RasMan', 'SstpSvc')
        StartType = 2
    }
    @{
        Name = 'Hyper-V'
        Description = 'Виртуализация, WSL2, Docker, песочница'
        Services = @('vmcompute', 'HvHost', 'vid')
        StartType = 2
    }
    @{
        Name = 'Microsoft Store'
        Description = 'Установка/обновление приложений из Store'
        Services = @('ClipSVC', 'AppXSvc')
        StartType = 2
    }
    @{
        Name = 'Иконки устройств'
        Description = 'Описания и иконки для принтеров, флешек'
        Services = @('DsmSvc')
        StartType = 2
    }
    @{
        Name = 'Факс'
        Description = 'Отправка и приём факсов'
        Services = @('Fax')
        StartType = 2
    }
)
