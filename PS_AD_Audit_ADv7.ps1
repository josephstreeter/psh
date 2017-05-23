Param([string]$PSDrive)

if ($PSDrive) {cd $PSDrive}

#If (-not ((gwmi win32_operatingsystem).caption -like "*Windows 8*")) {Write-Host "Script Requires Windows 8";Break}

Import-Module activedirectory
Import-Module GroupPolicy

Clear-Host

Function Get-DCInfo {
$Global:Forest = Get-ADForest
$Global:RootDomain = $Forest.rootdomain
$Global:PDCE = $Domain.PDCEmulator
}

Function Get-ForestInfo {
    "Forest Information"
    "###########################################"
    ""
    "Forest Name:              " + $Forest.name
    "Forest Root Domain:       " + $Forest.rootdomain
    "Forest Mode:              " + $Forest.forestmode
    "Operations Masters:"
    "    Schema Master:        " + $Forest.SchemaMaster
    "    Domain Naming Master: " + $Forest.DomainNamingMaster
    "Global Catalog Servers:"
    foreach ($GC in $Forest.GlobalCatalogs){"	                  " + $GC}
    ""
}

Function Get-DomainInfo {
    ""
    "Domain Information"
    "###########################################"
    ""
    foreach ($child in $Forest.Domains) {
        $Global:Domain = Get-ADDomain $child
        $Global:DN = $domain.DistinguishedName
    	"DNS Name:                " + $Domain.DNSRoot
        "NetBIOS Name:            " + $Domain.NetbiosName
    	"Domain Mode:             " + $Domain.DomainMode
    	"Domain SID:              " + $Domain.DomainSID
        "Operations Masters:"
	    "   PDC Emulator:         " + $Domain.PDCEmulator
	    "   Infrastrucure Master: " + $Domain.InfrastructureMaster
	    "   RID Master:           " + $Domain.RIDMaster 
	    ""
        "Domain Controllers:"
    	    $Global:DCs = $Domain.ReplicaDirectoryServers
		    foreach ($DC in $DCs) {"	                 " + $DC}
		    ""
	    "Read Only Domain Controllers: "
	    $RODCs = $Domain.ReadOnlyReplicaDirectoryServers
        if (-not($RODCs)) {
            "	                 none"
            } Else {
            foreach ($RODC in $RODCs){"	                     " + $RODC}
            }
        ""
        "Password Policies"
        "############################`n"
        $RootDSE = Get-ADRootDSE
        $PasswordPolicy = Get-ADObject $RootDSE.defaultNamingContext -Property minPwdAge, maxPwdAge, minPwdLength, pwdHistoryLength, pwdProperties 

        "Domain: $($PasswordPolicy.DistinguishedName)"
        "Max Password Age:     $($PasswordPolicy.maxPwdAge / -864000000000) days"
        "Min Password Age:     $($PasswordPolicy.minPwdAge / -864000000000) days"
        "Min Password Length:  $($PasswordPolicy.minPwdLength)"
        "Passwords Remembered: $($PasswordPolicy.pwdHistoryLength)"
        Switch ($PasswordPolicy.pwdProperties) {
            0 {"Passwprd Complexity: Passwords can be simple and the administrator account cannot be locked out"}
            1 {"Passwprd Complexity: Passwords must be complex and the administrator account cannot be locked out"}
            8 {"Passwprd Complexity: Passwords can be simple, and the administrator account can be locked out"}
            9 {"Passwprd Complexity: Passwords must be complex, and the administrator account can be locked out"}
            Default {$PasswordPolicy.pwdProperties}
            }
        ""
        }
        "Installed Options"
        "##############################"
        "Active Directory Recycle Bin: "
        If (("Windows2008R2Forest","Windows2012Forest","Windows2012R2Forest") -contains $Forest.forestmode ){
            If ((Get-ADOptionalFeature "Recycle Bin Feature").name){"AD Recycle Bin is enabled"}Else{"AD Recycle Bin is not enabled"
            }
        }Else{
        ""+ $Forest.forestmode + " doesn't support the AD Recyclebin"
        }

}

Function Get-DSInfo {

    $ADSchema = (Get-ADObject -identity "cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr ObjectVersion).ObjectVersion

    Switch ($ADSchema) {
        13 {$ADSchemaVersion = "Windows 2000"}
        30 {$ADSchemaVersion = "Windows 2003"}
        31 {$ADSchemaVersion = "Windows 2003 R2"}
        44 {$ADSchemaVersion = "Windows 2008"}
        47 {$ADSchemaVersion = "Windows 2008 R2"}
        56 {$ADSchemaVersion = "Windows 2012"}
        59 {$ADSchemaVersion = "Windows 2012 R2"}
        Default {$ADSchemaVersion = "Unknown"}
        }

    Try {$Exchange = (Get-ADObject -identity "cn=ms-exch-schema-version-pt,cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr rangeupper).rangeupper}
    Catch {$Exchange = 0}

    Switch ($Exchange) {
        4397   {$ExchangeVersion = "Exchange 2000 RTM"}
        4406   {$ExchangeVersion = "Exchange 2000 SP3"}
        6870   {$ExchangeVersion = "Exchange 2003 RTM"}
        6936   {$ExchangeVersion = "Exchange 2003 SP3"}
        10628  {$ExchangeVersion = "Exchange 2007 RTM"}
        11116  {$ExchangeVersion = "Exchange 2007 RTM"}
        14622  {$ExchangeVersion = "Exchange 2007 SP3 & Exchange 2010 RTM"}
        14726  {$ExchangeVersion = "Exchange 2010 SP1"}
        0      {$LyncVersion = "No Schema Present"}
        Default {$ExchangeVersion = "None"}
        }

    Try {$Lync = (Get-ADObject -identity "cn=ms-RTC-SIP-SchemaVersion ,cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr rangeupper).rangeupper}
    Catch {$Lync = 0}

    Switch ($Lync) {
        1006 {$LyncVersion = "Live Communications Server 2005"}
        1007 {$LyncVersion = "Office Communications Server 2007 R1"}
        1108 {$LyncVersion = "Office Communications Server 2007 R1"}
        1100 {$LyncVersion = "Lync Server 2010"}
        1150 {$LyncVersion = "Lync Server 2013"}
        0    {$LyncVersion = "No Schema Present"}
        Default {$LyncVersion = "None"}
        }

    Try {$SCCM = (Get-ADObject -identity "cn=mS-SMS-Version,cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr rangeupper).rangeupper}
    Catch {$SCCM = 0}

    Switch ($SCCM) {
        1006 {$SCCMVersion = "SMS"}
        1007 {$SCCMVersion = "SCCM"}
        1108 {$SCCMVersion = "SCCM"}
        0    {$SCCMVersion = "No Schema Present"}
        Default {$SCCMVersion = "No Schema Present"}
        }

    $Schema = New-Object System.Object
    $Schema | Add-Member -type NoteProperty -Name ActiveDirectory -Value $ADSchemaVersion
    $Schema | Add-Member -type NoteProperty -Name Exchange -Value $ExchangeVersion
    $Schema | Add-Member -type NoteProperty -Name Lync -Value $LyncVersion
    $Schema | Add-Member -type NoteProperty -Name SCCM -Value $SCCMVersion

    
    # Collect DS-Heuristics Settings

    $dSHeuristicsReport = @()
    $dSHeuristics = (Get-ADObject -identity "cn=Directory Service,cn=Windows NT,cn=Services,cn=Configuration,$DN" -pr dSHeuristics).dSHeuristics
    
    if ((-not ($dSHeuristics)) -or ($dSHeuristics[2] -eq "0")) {
        $ListObject = "Disabled"
        } Else {
        $ListObject = "Enabled"
        }

    if ((-not ($dSHeuristics)) -or ($dSHeuristics[6] -eq "0")) {
        $AnonAcc = "Disabled"
        } Else {
        $AnonAcc = "Enabled"
        }

    if ((-not ($dSHeuristics)) -or ($dSHeuristics[10] -eq "1")) {
        $UserPassword = "Real Password"
        } Else {
        $UserPassword = "Win 2000"
        }

    $dSH = New-Object System.Object
    $dSH | Add-Member -type NoteProperty -name ListObjectMode -value $ListObject
    $dSH | Add-Member -type NoteProperty -name AnonymousAccess -value $AnonAcc
    $dSH | Add-Member -type NoteProperty -name UserPasswordBehavior -value $UserPassword
    $dSHeuristicsReport += $dSH 
    
    # Collect Trust Information
    ""
    "Trusts"
    "###########################################"
    $TrustInfo = Get-ADObject -Filter {objectClass -eq "trustedDomain"} -Properties TrustPartner,TrustDirection,trustType
    If ($TrustInfo) {$TrustInfo | FT Name,TrustPartner,TrustDirection,TrustType,TrustStatus -AutoSize} Else {"No Trusts exist`n"}

    # Collect Site and Subnet Information
    
    $SiteListReport = @()
    $SiteLinkBridgeReport = @()
    $SiteLinkReport = @()
    $SiteSubnetReport = @()

    Foreach ($Site in $(Get-ADReplicationSite -Filter * -Properties *)) {
        $SiteList = New-Object System.Object
        $SiteList | Add-Member -Type NoteProperty -Name Name -Value $site.Name
        $SiteList | Add-Member -Type NoteProperty -Name Description -Value $site.Description
        $SiteList | Add-Member -Type NoteProperty -Name Location -Value $site.Location
        $SiteListReport += $SiteList
        }

    Foreach ($SiteLink in $(Get-ADReplicationSiteLink -Filter * -Properties *)) {
        $SiteLinkList = New-Object System.Object
        $SiteLinkList | Add-Member -Type NoteProperty -Name Name -Value $SiteLink.Name
        $SiteLinkList | Add-Member -Type NoteProperty -Name Description -Value $SiteLink.Description
        $SiteLinkList | Add-Member -Type NoteProperty -Name Cost -Value $SiteLink.Cost
        $SiteLinkList | Add-Member -Type NoteProperty -Name RepInterval -Value $SiteLink.Replinterval
        $SiteLinkList | Add-Member -Type NoteProperty -Name Options -Value $SiteLink.Options
        $SiteLinkList | Add-Member -Type NoteProperty -Name Protocol -Value $SiteLink.InterSiteTransportProtocol
        $SiteLinkList | Add-Member -Type NoteProperty -Name Sites -Value $($SiteLink.sitelist | % {(Get-ADReplicationsite $_).name})
        $SiteLinkReport += $SiteLinkList
        }

    Foreach ($SiteLinkBridge in $(Get-ADReplicationSiteLinkBridge -Filter * -Properties *)) {
        $SiteLinkBridgeList = New-Object System.Object
        $SiteLinkBridgeList | Add-Member -Type NoteProperty -Name BridgeName -Value $SiteLinkBridge.Name
        $SiteLinkBridgeList | Add-Member -Type NoteProperty -Name Description -Value $SiteLinkBridge.Description
        $SiteLinkBridgeReport += $SiteLinkBridgeList
        }

    Foreach ($SiteSubnet in $(Get-ADReplicationSubnet -Filter * -Properties *)) {
        $SiteSubnetList = New-Object System.Object
        $SiteSubnetList | Add-Member -Type NoteProperty -Name Name -Value $SiteSubnet.Name
        $SiteSubnetList | Add-Member -Type NoteProperty -Name Description -Value $SiteSubnet.Description
        $SiteSubnetList | Add-Member -Type NoteProperty -Name Site -Value $(Get-ADReplicationSite $SiteSubnet.Site).name
        $SiteSubnetList | Add-Member -Type NoteProperty -Name Location -Value $SiteSubnet.Location
        $SiteSubnetReport += $SiteSubnetList
        }

    ""
    "Schema Versions"
    "###########################################"
    $Schema | ft -AutoSize
    ""
    "DS-Heuristics Settings"
    "###########################################"
    $dSHeuristicsReport | ft -AutoSize
    ""
    "Site Information"
    "###########################################"
    ""
    "######### Sites #########"
    $SiteListReport | ft -AutoSize
    ""
    "######### Subnets #########"
    If ($SiteSubnetReport) {$SiteSubnetReport | ft -AutoSize} Else {"No Subnets exist`n"}
    ""
    "######### Site Link Bridge #########"
    If ($SiteLinkBridgeReport) {$SiteLinkBridgeReport | ft -AutoSize} Else {"No Site Link Bridges exist`n"}
    ""
    "######### Site Links #########"
    If ($SiteLinkReport) {$SiteLinkReport | ft -AutoSize} Else {"No Site Links exist`n"}
}

Function Get-GroupMemberships {
    "Sensitive Group Membership"
    "###########################################"
    ""
    $ServiceGroups = @("Enterprise Admins"
                        "Domain Admins"
                        "Schema Admins"
                        "Administrators"
                        "Account Operators"
                        "Server Operators"
                        "Incoming Forest Trust Builders"
                        "Pre-Windows 2000 Compatible Access"
                        )
    foreach ($group in $ServiceGroups) {
        $GroupMembers = Get-ADGroup $group -pr members
        $group + " " + ($GroupMembers.members).count
        If (($GroupMembers.members).count -gt 0) {
            Foreach ($Member in $GroupMembers.members) {
                "  " + (Get-ADobject $Member).name
                }
            }
        ""
        }
    ""
}

Function Get-DomainControllers {
    
    # Collecting Security Policy Settings

    $FilesReport = @()
    $LDAPReport = @()
    $Timeoff = @()
    $DIAGReport = @()
    $NTPReport = @()
    $IfReport = @()
    $SvcReport = @()
    $StaticPortsReport = @()

    Foreach ($DC in $DCs) {
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $DC)

    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("ldapserverintegrity")))
        {
        "0" {$DCSinging = "None"}
        "1" {$DCSinging = "Negotiate"}
        "2" {$DCSinging = "Require Signing"}
        default {$DCSinging = "Unknown"}
        }

    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\LDAP").GetValue("LDAPClientIntegrity")))
        {
        "0" {$CLSigning = "None"}
        "1" {$CLSigning = "Negotiate Signing"}
        "2" {$CLSigning =  "Require Signing"}
        default {$CLSigning = "Unknown"}
        }

    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("NoLMHash")))
        {
        "0" {$LMPWD = "Disabled"}
        "1" {$LMPWD = "Enabled"}
        default {$LMPWD = "Unknown"}
        }

    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("LmCompatibilityLevel")))
        {
        "0" {$LMAuth = "Send LM & NTLM responses"}
        "1" {$LMAuth = "Send LM & NTLM - use NTLMv2 session security if negotiated"}
        "2" {$LMAuth = "Send NTLM response only"}
        "3" {$LMAuth = "Send NTLMv2 response only"}
        "4" {$LMAuth = "Send NTLMv2 response only\refuse LM"}
        "5" {$LMAuth = "Send NTLMv2 response only\refuse LM & NTLM"}
        default {$LMAuth = "Unknown"}
        }

    $LDAP = New-Object System.Object
    $LDAP | Add-Member -type NoteProperty -name Server -value $DC
    $LDAP | Add-Member -type NoteProperty -name DCSinging -value $DCSinging
    $LDAP | Add-Member -type NoteProperty -name CLSigning -value $CLSigning 
    $LDAP | Add-Member -type NoteProperty -name LMPWD -value $LMPWD
    $LDAP | Add-Member -type NoteProperty -name LMAuth -value $LMAuth
    $LDAPReport += $LDAP 

    # Collecting SYSVOL, Database, and Log File Locations
    $NTDS =   $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
    $SYSVOL = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("SysVol")
    $SYSTEM = $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion").GetValue("SystemRoot")
    $Logs =   $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("Database log files path")
        
    $Files = New-Object System.Object
    $Files | Add-Member -type NoteProperty -name Server -value $DC
    $Files | Add-Member -type NoteProperty -name NTDS -value $NTDS
    $Files | Add-Member -type NoteProperty -name SYSVOL -value $SYSVOL
    $Files | Add-Member -type NoteProperty -name System -value $SYSTEM
    $Files | Add-Member -type NoteProperty -name Logs -value $Logs
    $FilesReport += $Files 
    
    # Collect Network Interface Settigns
    $Interface = (Get-WMIObject Win32_NetworkAdapterConfiguration -computername $DC | where{$_.IPEnabled -eq “TRUE”})

    $IfProp = New-Object System.Object
    $IfProp | Add-Member -type NoteProperty -name Server -value $DC        
    $IfProp | Add-Member -type NoteProperty -name IPAddress -value $Interface.IPAddress
    $IfProp | Add-Member -type NoteProperty -name IPSubnet -value $Interface.IPSubnet
    $IfProp | Add-Member -type NoteProperty -name DefaultGateway -value $Interface.DefaultIPGateway
    $IfProp | Add-Member -type NoteProperty -name DNSServerSearchOrder -value $Interface.DNSServerSearchOrder
    $IfProp | Add-Member -type NoteProperty -name DHCPEnabled -value $Interface.DHCPEnabled
    $IfProp | Add-Member -type NoteProperty -name DNSDomain -value $Interface.DNSDomain
    $IfProp | Add-Member -type NoteProperty -name DNSSearchOrder -value $Interface.DNSDomainSuffixSearchOrder
    $IfProp | Add-Member -type NoteProperty -name DNSWINSRes -value $Interface.DNSEnabledForWINSResolution
    $IfProp | Add-Member -type NoteProperty -name FullDNSReg -value $Interface.FullDNSRegistrationEnabled
    $IfReport += $IfProp
    
    # Collect Static Port Information 
    $NTFRS = $reg.OpenSubKey("System\CurrentControlSet\Services\NTFRS\Parameters").GetValue("RPC TCP/IP Port Assignment")
    $DFSR = $reg.OpenSubKey("System\CurrentControlSet\Services\DFSR\Parameters").GetValue("RPC TCP/IP Port Assignment")
    $RPC = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("TCP/IP Port")
    $Netlogon = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("DCTCPIPPort")

    $StaticPorts = New-Object System.Object
    $StaticPorts | Add-Member -type NoteProperty -name Server -Value "$($DC)  "
    $StaticPorts | Add-Member -type NoteProperty -name NTFRS -Value $(If ($NTFRS){"$($NTFRS)  "}Else{"No Static Port Assigned  "})
    $StaticPorts | Add-Member -type NoteProperty -name DFSR -Value $(If ($DFSR){"$($DFSR)  "}Else{"No Static Port Assigned  "})
    $StaticPorts | Add-Member -type NoteProperty -name RPC -Value $(If ($RPC){"$($RPC)  "}Else{"No Static Port Assigned  "})
    $StaticPorts | Add-Member -type NoteProperty -name Netlogon -Value $(If ($Netlogon){"$($Netlogon)  "}Else{"No Static Port Assigned  "})
    $StaticPortsReport += $StaticPorts
    
    # Collect Time Offset
    $NTPServer = $reg.OpenSubKey("SOFTWARE\Policies\Microsoft\W32Time\Parameters").GetValue("NTPServer")
    $NTPType = $reg.OpenSubKey("SOFTWARE\Policies\Microsoft\W32Time\Parameters").GetValue("Type")
    
    $NTPProp = New-Object System.Object
    $NTPProp | Add-Member -type NoteProperty -Name Server -value $DC
    $NTPProp | Add-Member -type NoteProperty -Name NTPServer -value $NTPServer.Split(",")[0]
    $NTPProp | Add-Member -type NoteProperty -Name NTPServerS -value $NTPServer.Split(",")[1]
    $NTPProp | Add-Member -type NoteProperty -Name NTPType -value $NTPType
    $NTPProp | Add-Member -type NoteProperty -Name PDCE -value $(If ($DC -eq $PDCE){"TRUE"}Else{"FALSE"})
    $NTPReport += $NTPProp 
    
    $Time = w32tm /stripchart /dataonly /computer:$DC /samples:1
    $Timeoff += New-object PSObject -Property @{
        Server = $Time[0].Replace("Tracking","").Trim()
        Time =   $Time[2].Replace("The current time is","").Trim()
        Offset = $Time[3].Split(",")[1]
        }

    # Collect AD Diagnostic Logging Settings
    $Keys = @(
        "1 Knowledge Consistency Checker"
        "2 Security Events"
        "3 ExDS Interface Events"
        "4 MAPI Interface Events"
        "5 Replication Events"
        "6 Garbage Collection"
        "7 Internal Configuration"
        "8 Directory Access"
        "9 Internal Processing"
        "10 Performance Counters"
        "11 Initialization/Termination"
        "12 Service Control"
        "13 Name Resolution"
        "14 Backup"
        "15 Field Engineering"
        "16 LDAP Interface Events"
        "17 Setup"
        "18 Global Catalog"
        "19 Inter-site Messaging")

    $DIAG = New-Object System.Object
    $DIAG | Add-Member -type NoteProperty -name Server -value $DC
    Foreach ($Key in $Keys) {
        Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Diagnostics").GetValue($Key)))
            {
            "0" {$Level = "None"}
            "1" {$Level = "Minimal"}
            "2" {$Level = "Basic"}
            "3" {$Level = "Extensive"}
            "4" {$Level = "Verbose"}
            "5" {$Level = "Internal"}
            default {$Level = "Unknown"}
            }
        $DIAG | Add-Member -type NoteProperty -name $Key -value $Level
        }
        $DIAGReport += $DIAG
    
    # Collect Service Information

    $SvcStatus = New-Object System.Object
    $SvcStatus | Add-Member -type NoteProperty -Name Server -Value "$($DC)  "
    $SvcStatus | Add-Member -type NoteProperty -Name DNS -Value "$((get-service -ComputerName $DC DNS).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name DNSClient -Value "$((get-service -ComputerName $DC Dnscache).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name DHCP -Value "$((get-service -ComputerName $DC DHCP).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name KDC -Value "$((get-service -ComputerName $DC KDC).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name NTDS -Value "$((get-service -ComputerName $DC NTDS).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name Time -Value "$((get-service -ComputerName $DC W32Time).Status)  "
    $SvcStatus | Add-Member -type NoteProperty -Name FRSR -Value "$((get-service -ComputerName $DC NTfrs).Status)  "
    $SvcReport += $SvcStatus
    }

    ""
    "Domain Controller Security Policy"
    "###########################################"
    "Domain controller: LDAP server signing requirements"
    "Network security: LDAP client signing requirements"
    "Network security: Do not store LAN Manager hash value on next password change"
    "Network security: LAN Manager authentication level"
    "###########################################"
    $LDAPReport | sort server | ft -AutoSize
    ""
    "SYSVOL, Database, and Log File Locations"
    "###########################################"
    $FilesReport | sort server | ft -AutoSize
    ""
    "Network Interface Properties"
    "###########################################"
    $IfReport | sort server | ft -AutoSize
    ""
    "Static Ports"
    "###########################################"
    $StaticPortsReport | ft -AutoSize
    ""
    "NTP Settings"
    "###########################################"
    $NTPReport | ft -AutoSize
    ""
    "NTP Time Offset"
    "###########################################"
    $timeoff | select Server,time,offset | ft -AutoSize
    ""
    "Service Information"
    "###########################################`n" 
    $SvcReport | Sort Server | ft -AutoSize
    ""
    "Diagnostic Logging Settings"
    "###########################################`n" 
    $DIAGReport | fl
}

Function Get-DNSInfo {

    $ScavengeReport = @()
    $RecurReport = @()
    $ZoneReport = @()
    $ZoneScavReport = @()
    $CacheReport = @()
    $ForwardReport = @()
    $ServerReport = @()

    Foreach ($DC in $DCs) {
        $DNSSettings = Get-DnsServer -computer $DC -WarningAction SilentlyContinue

        # Collect DNS Server Configuration
        $ServerProp = New-Object System.Object
        $ServerProp | Add-Member -type NoteProperty -name Server -value $DC
        $ServerProp | Add-Member -type NoteProperty -name EnableIPv6 -value $DNSSettings.ServerSetting.EnableIPv6
        $ServerProp | Add-Member -type NoteProperty -name AllIPAddress -value $DNSSettings.ServerSetting.AllIPAddress
        $ServerProp | Add-Member -type NoteProperty -name EnableWinsR -value $DNSSettings.ServerSetting.EnableWinsR
        $ServerProp | Add-Member -type NoteProperty -name AllowUpdate -value $DNSSettings.ServerSetting.AllowUpdate
        $ServerProp | Add-Member -type NoteProperty -name RoundRobin -value $DNSSettings.ServerSetting.RoundRobin
        $ServerProp | Add-Member -type NoteProperty -name BindSecond -value $DNSSettings.ServerSetting.BindSecondaries
        $ServerProp | Add-Member -type NoteProperty -name EnableDnsSec -value $DNSSettings.ServerSetting.EnableDnsSec
        $ServerProp | Add-Member -type NoteProperty -name EnableUpdateFwd -value $DNSSettings.ServerSetting.EnableUpdateForwarding
        $ServerReport += $ServerProp 

        # Collect DNS Server Scavenging Configuration
        $ScavengeProp = New-Object System.Object
        $ScavengeProp | Add-Member -type NoteProperty -name Server -value $DC
        $ScavengeProp | Add-Member -type NoteProperty -name LastScavengeTime -value $DNSSettings.ServerScavenging.LastScavengeTime
        $ScavengeProp | Add-Member -type NoteProperty -name NoRefreshInterval -value $DNSSettings.ServerScavenging.NoRefreshInterval 
        $ScavengeProp | Add-Member -type NoteProperty -name ScavengingInterval -value $DNSSettings.ServerScavenging.ScavengingInterval
        $ScavengeProp | Add-Member -type NoteProperty -name ScavengingState -value $DNSSettings.ServerScavenging.ScavengingState 
        $ScavengeReport += $ScavengeProp

        # Collect DNS Server Recursion Configuration
        $RecurProp = New-Object System.Object
        $RecurProp | Add-Member -type NoteProperty -name Server -value $DC
        $RecurProp | Add-Member -type NoteProperty -name RecursionEnable -value $DNSSettings.ServerRecursion.Enable
        $RecurProp | Add-Member -type NoteProperty -name AdditionalTimeout -value $DNSSettings.ServerRecursion.AdditionalTimeout
        $RecurProp | Add-Member -type NoteProperty -name RetryInterval -value $DNSSettings.ServerRecursion.RetryInterval
        $RecurProp | Add-Member -type NoteProperty -name Timeout -value $DNSSettings.ServerRecursion.Timeout
        $RecurProp | Add-Member -type NoteProperty -name SecureResponse  -value $DNSSettings.ServerRecursion.SecureResponse 
        $RecurReport += $RecurProp

        # Collect DNS Server Cache Configuration
        $CacheProp = New-Object System.Object
        $CacheProp | Add-Member -type NoteProperty -name Server -value $DC
        $CacheProp | Add-Member -type NoteProperty -name MaxTTL -value $DNSSettings.ServerCache.MaxTtl
        $CacheProp | Add-Member -type NoteProperty -name MaxNegTTL -value $DNSSettings.ServerCache.MaxNegativeTtl
        $CacheProp | Add-Member -type NoteProperty -name EnablePollProt -value $DNSSettings.ServerCache.EnablePollutionProtection
        $CacheReport += $CacheProp

        # Collect DNS Server Forwarder Configuration
        $ForwardProp = New-Object System.Object
        $ForwardProp | Add-Member -type NoteProperty -name Server -value $DC
        $ForwardProp | Add-Member -type NoteProperty -name IPAddress -value $DNSSettings.ServerForwarder.IPAddress
        $ForwardProp | Add-Member -type NoteProperty -name UseRootHint -value $DNSSettings.ServerForwarder.UseRootHint
        $ForwardProp | Add-Member -type NoteProperty -name Timeout -value $DNSSettings.ServerForwarder.Timeout
        $ForwardReport += $ForwardProp 

    # Collect DNS Zone Information
    Foreach ($ZoneSrv in ($DNSSettings.ServerZone | ? {$_.IsAutoCreated -eq $false})) {
        $ZoneProp = New-Object System.Object
        $ZoneProp | Add-Member -type NoteProperty -name Server -value $DC
        $ZoneProp | Add-Member -type NoteProperty -name ZoneName -value $ZoneSrv.ZoneName
        $ZoneProp | Add-Member -type NoteProperty -name ZoneType -value $ZoneSrv.ZoneType
        $ZoneProp | Add-Member -type NoteProperty -name DynamicUpdate -value $ZoneSrv.DynamicUpdate
        $ZoneProp | Add-Member -type NoteProperty -name DSIntegrated -value $ZoneSrv.IsDsIntegrated
        $ZoneProp | Add-Member -type NoteProperty -name ReverseLookup -value $ZoneSrv.IsReverseLookupZone
        $ZoneProp | Add-Member -type NoteProperty -name WINSEnabled -value $ZoneSrv.IsWinsEnabled
        $ZoneProp | Add-Member -type NoteProperty -name ReplicationScope -value $ZoneSrv.ReplicationScope
        $ZoneProp | Add-Member -type NoteProperty -name SecureSecondaries -value $ZoneSrv.SecureSecondaries
        $ZoneReport += $ZoneProp
    }

    Foreach ($ZoneScav in $DNSSettings.ServerZoneAging) {
        $ZoneScavProp = New-Object System.Object
        $ZoneScavProp | Add-Member -type NoteProperty -name Server -value $DC
        $ZoneScavProp | Add-Member -type NoteProperty -name ZoneName -value $ZoneScav.ZoneName
        $ZoneScavProp | Add-Member -type NoteProperty -name AgingEnabled -value $ZoneScav.AgingEnabled
        $ZoneScavProp | Add-Member -type NoteProperty -name AvailForScavengeTime -value $ZoneScav.AvailForScavengeTime
        $ZoneScavProp | Add-Member -type NoteProperty -name RefreshInterval -value $ZoneScav.RefreshInterval
        $ZoneScavProp | Add-Member -type NoteProperty -name NoRefreshInterval -value $ZoneScav.NoRefreshInterval
        $ZoneScavProp | Add-Member -type NoteProperty -name ScavengeServers -value $ZoneScav.ScavengeServers
        $ZoneScavReport += $ZoneScavProp
    }
}
    # Print Reports
    "DNS Server Information"
    "###########################################"
    $ServerReport | ft -AutoSize
    ""
    "######### Scavenging Settings #########"
    $ScavengeReport | ft -AutoSize
    ""
    "######### Recusive Settings #########"
    $RecurReport | ft -AutoSize
    ""
    "######### Forwarder Settings #########"
    $ForwardReport | sort ZoneName, server | ft -AutoSize
    ""
    "######### Cache Settings #########"
    $CacheReport | ft -AutoSize
    ""
    "######### Zone Scavenging Settings #########"
    ($ZoneScavReport.ZoneName | sort | group).name | % {$zn = $_ ; "" ; "##########" ; $ZoneScavReport | ?{$_.ZoneName -eq "$zn"}} | ft -AutoSize
    ""
    "######### Zone Settings #########"
    ($ZoneReport.ZoneName | sort | group).name | % {$zn = $_ ; "" ; "`n##########" ; $ZoneReport | ?{$_.ZoneName -eq "$zn"}} | ft -AutoSize
}

Function Get-GPOInfo {
$GPOs  = Get-GPO -All 
$GPOLinkReport = @()
$GPOSyncReport = @()

Foreach ($GPO in $GPOs) {
    If ( $GPO | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ){
        $GPOLink = New-Object System.Object
        $GPOLink | Add-Member -Name DisplayName -Type NoteProperty -Value $GPO.DisplayName
        $GPOLink | Add-Member -Name DomainName -Type NoteProperty -Value $GPO.DomainName
        $GPOLink | Add-Member -Name GPOStatus -Type NoteProperty -Value $GPO.GpoStatus
        $GPOLink | Add-Member -Name Description -Type NoteProperty -Value $GPO.Description
        $GPOLink | Add-Member -Name Created -Type NoteProperty -Value $GPO.CreationTime
        $GPOLink | Add-Member -Name Modified -Type NoteProperty -Value $GPO.ModificationTime
        $GPOLink | Add-Member -Name UserVersion -Type NoteProperty -Value $("AD Ver: "+$GPO.User.DSVersion+" SYSVOL Ver: "+ $GPO.User.SysvolVersion)
        $GPOLink | Add-Member -Name ComputerVersion -Type NoteProperty -Value $("AD Ver: "+$GPO.Computer.DSVersion+" SYSVOL Ver: "+ $GPO.Computer.SysvolVersion)
        $GPOLink | Add-Member -Name WMIFilter -Type NoteProperty -Value $GPO.WMIFilter
        $GPOLinkReport += $GPOLink
        }
    }

Foreach ($GPO in $GPOs) {
    If (($GPO.User.DSVersion -ne $GPO.User.SysvolVersion) -or ($GPO.Computer.DSVersion -ne $GPO.Computer.SysvolVersion)){
        $GPOSync = New-Object System.Object
        $GPOSync | Add-Member -Name DisplayName -Type NoteProperty -Value $GPO.DisplayName
        $GPOSync | Add-Member -Name DomainName -Type NoteProperty -Value $GPO.DomainName
        $GPOSync | Add-Member -Name GPOStatus -Type NoteProperty -Value $GPO.GpoStatus
        $GPOSync | Add-Member -Name Description -Type NoteProperty -Value $GPO.Description
        $GPOSync | Add-Member -Name Created -Type NoteProperty -Value $GPO.CreationTime
        $GPOSync | Add-Member -Name Modified -Type NoteProperty -Value $GPO.ModificationTime
        $GPOSync | Add-Member -Name UserVersion -Type NoteProperty -Value $("AD Ver: "+$GPO.User.DSVersion+" SYSVOL Ver: "+ $GPO.User.SysvolVersion)
        $GPOSync | Add-Member -Name ComputerVersion -Type NoteProperty -Value $("AD Ver: "+$GPO.Computer.DSVersion+" SYSVOL Ver: "+ $GPO.Computer.SysvolVersion)
        $GPOSync | Add-Member -Name WMIFilter -Type NoteProperty -Value $GPO.WMIFilter
        $GPOSyncReport += $GPOSync
        }
    }

$GPOLinkReport | ft
$GPOSyncReport | ft
}

Get-DCInfo
"Gathering Forest Information"
Get-ForestInfo | Out-File C:\Scripts\Rpt-ForestInfo.txt -width 180
"Gathering Domain Information"
Get-DomainInfo | Out-File -append C:\Scripts\Rpt-ForestInfo.txt -width 180
"Gathering Directory Services Information"
Get-DSInfo | Out-File -append C:\Scripts\Rpt-ForestInfo.txt -width 180
"Gathering Security Group Information"
Get-GroupMemberships | Out-File C:\Scripts\Rpt-Groupmemberships.txt -width 180
"Gathering DOmain Controller Information"
Get-DomainControllers | Out-File C:\Scripts\Rpt-DomainControllers.txt -width 180
"Gathering DNS Service Information"
Get-DNSInfo | Out-File C:\Scripts\Rpt-DNSInfo.txt -width 180
"Gathering Group Policy Object Information"
Get-GPOInfo | Out-File C:\Scripts\Rpt-GPO.txt -width 180