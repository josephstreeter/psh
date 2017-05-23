CLS

$DCs = $((Get-ADDomainController -filter {(-not(hostname -eq "MCRODC.MATC.Madison.Login")) -and (-not(hostname -eq "MDCSYNC.MATC.Madison.Login"))}).hostname)

$Global:Forest = Get-ADForest
$Global:RootDomain = $Forest.rootdomain
$Global:PDCE = $Domain.PDCEmulator

Function Get-ForestInfo 
    {
    
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

Function Get-GroupMemberships 
    {
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
    foreach ($group in $ServiceGroups) 
        {
        if ($GroupMembers = (Get-ADGroupMember $Group -Recursive -ea 0))
            {
            $group + " " + ($GroupMembers.distinguishedname).count
            If (($GroupMembers.distinguishedname).count -gt 0) 
                {
                Foreach ($Member in $GroupMembers.distinguishedname) 
                    {
                    "  " + (Get-ADobject $Member -ea 0).name
                    }
                }
            }
            Else
            {
            "Error"
            }

        ""
        }
    ""
    }

Function Get-DCInfo 
    {
    
    $HKCR = 2147483648 #HKEY_CLASSES_ROOT
    $HKCU = 2147483649 #HKEY_CURRENT_USER
    $HKLM = 2147483650 #HKEY_LOCAL_MACHINE
    $HKUS = 2147483651 #HKEY_USERS
    $HKCC = 2147483653 #HKEY_CURRENT_CONFIG
    
    $PropArray = @()
    $DiagArray = @()
    
    Foreach ($DC in $DCs) 
        {
        $reg = [wmiclass]"\\$DC\root\default:StdRegprov"

        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name Server -value $DC
        
        $key = "System\CurrentControlSet\Control\Lsa"
        $Prop | Add-Member -type NoteProperty -name NoLMHash -value $(If ($reg.GetDwordValue($HKLM, $key, "NoLMHash").uValue -eq 0){"False"}Else{"True"})
        Switch ($reg.GetDwordValue($HKLM, $key, "LmCompatibilityLevel").uValue)
            {
            "0" {$LMAuth = "Send LM & NTLM responses"}
            "1" {$LMAuth = "Send LM & NTLM - use NTLMv2 session security if negotiated"}
            "2" {$LMAuth = "Send NTLM response only"}
            "3" {$LMAuth = "Send NTLMv2 response only"}
            "4" {$LMAuth = "Send NTLMv2 response only\refuse LM"}
            "5" {$LMAuth = "Send NTLMv2 response only\refuse LM & NTLM"}
            default {$LMAuth = "Unknown"}
            }
        $Prop | Add-Member -type NoteProperty -name "LmCompatibilityLevel" -value $LMAuth
        $key = "System\CurrentControlSet\Services\LDAP"
        Switch ($($reg.GetDwordValue($HKLM, $key, "ldapclientintegrity").uValue))
            {
            "0" {$ClntSinging = "None"}
            "1" {$ClntSinging = "Negotiate"}
            "2" {$ClntSinging = "Require Signing"}
            default {$ClntSinging = "Unknown"}
            }
        $Prop | Add-Member -type NoteProperty -name "LDAPClientIntegrity" -value $ClntSinging
    
        $key = "System\CurrentControlSet\Services\NTDS\Parameters"
        Switch ($($reg.GetDwordValue($HKLM, $key, "ldapserverintegrity").uValue))
            {
            "0" {$DCSinging = "None"}
            "1" {$DCSinging = "Negotiate"}
            "2" {$DCSinging = "Require Signing"}
            default {$DCSinging = "Unknown"}
            }
        $Prop | Add-Member -type NoteProperty -name "LDAPServerIntegrity" -value $DCSinging
        $Prop | Add-Member -type NoteProperty -name "Database log files path" -value $reg.GetStringValue($HKLM, $key, "Database log files path").sValue
        $Prop | Add-Member -type NoteProperty -name "DSA Working Directory" -value $reg.GetStringValue($HKLM, $key, "DSA Working Directory").sValue
    
        $key = "System\CurrentControlSet\Services\NetLogon\Parameters"
        $Prop | Add-Member -type NoteProperty -name "SYSVOL files path" -value $reg.GetStringValue($HKLM, $key, "SYSVOL").sValue
        
        $key = "Software\Microsoft\Windows NT\CurrentVersion\" 
        $Prop | Add-Member -type NoteProperty -name "SystemRoot" -value $reg.GetStringValue($HKLM, $key, "SystemRoot").sValue

        $key = "SOFTWARE\Policies\Microsoft\W32Time\Parameters"
        $NTPServer = $reg.GetDwordValue($HKLM, $key, "NTPServer").uValue
        $NTPTYpe = $reg.GetDwordValue($HKLM, $key, "Type").uValue
        $Prop | Add-Member -type NoteProperty -name NTPServer -value $(If ($NTPServer){$NTPServer.Split(",")[0]}Else{"Not Configured"})
        $Prop | Add-Member -type NoteProperty -name NTPServerOffset -value $(If ($NTPServer){$NTPServer.Split(",")[1]}Else{"Not Configured"})
        $Prop | Add-Member -type NoteProperty -name NTPType -value $(If ($NTPType){$NTPType}Else{"Not Configured"})    
        $Prop | Add-Member -type NoteProperty -Name PDCE -value $(If ($DC -eq $PDCE){"TRUE"}Else{"FALSE"})

        $Key = "System\CurrentControlSet\Services\NTFRS\Parameters"
        $RPC = $reg.GetDwordValue($HKLM, $key, "RPC TCP/IP Port Assignment").uValue
        $Prop | Add-Member -type NoteProperty -name "RPC TCP/IP Port Assignment" -value $(If ($RPC){$RPC}Else{"Not Configured"})
    
        $Key = "System\CurrentControlSet\Services\DFSR\Parameters"
        $DFSR = $reg.GetDwordValue($HKLM, $key, "RPC TCP/IP Port Assignment").uValue
        $Prop | Add-Member -type NoteProperty -name "DFSR TCP/IP Port Assignment" -value $(If ($DFSR){$DFSR}Else{"Not Configured"})
    
        $Key = "System\CurrentControlSet\Services\NTDS\Parameters"
        $NTDS = $reg.GetDwordValue($HKLM, $key, "TCP/IP Port").uValue
        $Prop | Add-Member -type NoteProperty -name "TCP/IP Port" -value $(If ($NTDS){$NTDS}Else{"Not Configured"})
        $PropArray += $Prop

        
        
        $Diag = New-Object System.Object    
        $key = "System\CurrentControlSet\Services\NTDS\Diagnostics"
        
        $DiagSettings = 
        "1 Knowledge Consistency Checker,$($reg.GetDwordValue($HKLM, $key, '1 Knowledge Consistency Checker').uValue)",
        "2 Security Events,$($reg.GetDwordValue($HKLM, $key, '2 Security Events').uValue)",
        "3 ExDS Interface Events,$($reg.GetDwordValue($HKLM, $key, '3 ExDS Interface Events').uValue)",
        "4 MAPI Interface Events,$($reg.GetDwordValue($HKLM, $key, '4 MAPI Interface Events').uValue)",
        "5 Replication Events,$($reg.GetDwordValue($HKLM, $key, '5 Replication Events').uValue)",
        "6 Garbage Collection,$($reg.GetDwordValue($HKLM, $key, '6 Garbage Collection').uValue)",
        "7 Internal Configuration,$($reg.GetDwordValue($HKLM, $key, '7 Internal Configuration').uValue)",
        "8 Directory Access,$($reg.GetDwordValue($HKLM, $key, '8 Directory Access').uValue)",
        "9 Internal Processing,$($reg.GetDwordValue($HKLM, $key, '9 Internal Processing').uValue)",
        "10 Performance Counters,$($reg.GetDwordValue($HKLM, $key, '10 Performance Counters').uValue)",
        "11 Initialization/Termination,$($reg.GetDwordValue($HKLM, $key, '11 Initialization/Termination').uValue)",
        "12 Service Control,$($reg.GetDwordValue($HKLM, $key, '12 Service Control').uValue)",
        "13 Name Resolution,$($reg.GetDwordValue($HKLM, $key, '13 Name Resolution').uValue)",
        "14 Backup,$($reg.GetDwordValue($HKLM, $key, '14 Backup').uValue)",
        "15 Field Engineering,$($reg.GetDwordValue($HKLM, $key, '15 Field Engineering').uValue)",
        "16 LDAP Interface Events,$($reg.GetDwordValue($HKLM, $key, '16 LDAP Interface Events').uValue)",
        "17 Setup,$($reg.GetDwordValue($HKLM, $key, '17 Setup').uValue)",
        "18 Global Catalog,$($reg.GetDwordValue($HKLM, $key, '18 Global Catalog').uValue)",
        "19 Inter-site Messaging,$($reg.GetDwordValue($HKLM, $key, '19 Inter-site Messaging').uValue)",
        "20 Group Caching,$($reg.GetDwordValue($HKLM, $key, '20 Group Caching').uValue)",
        "21 Linked-Value Replication,$($reg.GetDwordValue($HKLM, $key, '21 Linked-Value Replication').uValue)",
        "22 DS RPC Client,$($reg.GetDwordValue($HKLM, $key, '22 DS RPC Client').uValue)",
        "23 DS RPC Server,$($reg.GetDwordValue($HKLM, $key, '23 DS RPC Server').uValue)",
        "24 DS Schema,$($reg.GetDwordValue($HKLM, $key, '24 DS Schema').uValue)"
        
        $Diag | Add-Member -type NoteProperty -name Server -value $DC
        Foreach ($DiagSetting in $DiagSettings)
            {
            Switch ($DiagSetting.split(",")[1])
                {
                "0" {$DiagLevel = "None"}
                "1" {$DiagLevel = "Minimal"}
                "2" {$DiagLevel = "Basic"}
                "3" {$DiagLevel = "Extensive"}
                "4" {$DiagLevel = "Verbose"}
                "5" {$DiagLevel = "Internal"}
                default {$ClntSinging = "Unknown"}
                }  
            
            $Diag | Add-Member -type NoteProperty -name $DiagSetting.split(",")[0] -value $DiagLevel
            }
        $DiagArray += $Diag

        <#
        GetBinaryValue
        GetDWORDValue
        GetExpandedStringValue
        GetMultiStringValue
        GetQWORDValue
        GetSecurityDescriptor              
        GetStringValue      
        #>
 
        }
    
    $proparray | ft "Server","NoLMHash","LmCompatibilityLevel","LDAPClientIntegrity","LDAPServerIntegrity" -AutoSize
    $proparray | ft "Server","Database log files path"."DSA Working Directory","SYSVOL files path","SystemRoot" -AutoSize
    $proparray | ft "Server","NTPServer","NTPServerOffset","NTPType","PDCE" -AutoSize
    $proparray | ft "Server","RPC TCP/IP Port Assignment","DFSR TCP/IP Port Assignment","TCP/IP Port" -AutoSize
    
    $DiagArray
    }

Function Get-DSInfo 
    {

    Try {$ADSchema = (Get-ADObject -identity "cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr ObjectVersion -ErrorAction SilentlyContinue).ObjectVersion}
    Catch {$ADSchema = "Not Available"}

    Switch ($ADSchema) {
        13 {$ADSchemaVersion = "Windows 2000"}
        30 {$ADSchemaVersion = "Windows 2003"}
        31 {$ADSchemaVersion = "Windows 2003 R2"}
        44 {$ADSchemaVersion = "Windows 2008"}
        47 {$ADSchemaVersion = "Windows 2008 R2"}
        66 {$ADSchemaVersion = "Windows 2012"}
        69 {$ADSchemaVersion = "Windows 2012 R2"}
        Default {$ADSchemaVersion = "Unknown ("+$ADSchemaVersion+")"}
        }

    Try {$Exchange = (Get-ADObject -identity "cn=ms-exch-schema-version-pt,cn=Schema,cn=Configuration,$((get-addomain).distinguishedname)" -pr rangeupper).rangeupper}
    Catch {$Exchange = 0}

    Switch ($Exchange) {
        4397   {$ExchangeVersion = "Exchange 2000 RTM"}
        4406   {$ExchangeVersion = "Exchange 2000 SP3"}
        6870   {$ExchangeVersion = "Exchange 2003 RTM"}
        6936   {$ExchangeVersion = "Exchange 2003 SP3"}
        10628  {$ExchangeVersion = "Exchange 2007 RTM"}
        10637  {$ExchangeVersion = "Exchange 2007"}
        11116  {$ExchangeVersion = "Exchange 2007 RTM"}
        14622  {$ExchangeVersion = "Exchange 2007 SP3 & Exchange 2010 RTM"}
        14726  {$ExchangeVersion = "Exchange 2010 SP1"}
        15137  {$ExchangeVersion = "Exchange 2013"}
        0      {$ExchangeVersion = "No Schema Present"}
        Default {$ExchangeVersion = "Unknown ($Exchange)"}
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
    
    "`nSchema Versions"
    "###########################################"
    $Schema | ft -AutoSize
    
    # Collect DS-Heuristics Settings

    $dSHeuristicsReport = @()
    Try {$dSHeuristics = (Get-ADObject -identity "cn=Directory Service,cn=Windows NT,cn=Services,cn=Configuration,$DN" -pr dSHeuristics -ErrorAction SilentlyContinue).dSHeuristics}
    Catch {}
    
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
    
    "`nDS-Heuristics Settings"
    "###########################################"
    $dSHeuristicsReport | ft -AutoSize

    # Collect ms-ds-MachineAccountQuota

    $MachineaccountQuota = (Get-ADObject -identity $DN -pr ms-DS-MachineAccountQuota)."ms-DS-MachineAccountQuota"
    
    "`nms-ds-MachineAccountQuota Setting"
    "###########################################"
    $MachineaccountQuota

    # LDAP Max Idle Time
        
    Try {$LDAPAdminLimits = (Get-ADObject -identity "cn=Default Query Policy,cn=Query-Policies,cn=Directory Service, cn=Windows NT,cn=Services,cn=Configuration,$DN" -pr LDAPAdminLimits -ErrorAction SilentlyContinue).LDAPAdminLimits}
    Catch {}
    
    "`nLDAP Max Timeout Setting"
    "###########################################"    
    $LDAPAdminLimits[10]
    
    # Collect Trust Information

    $TrustReport = @()
    
    $Trusts = Get-ADObject -Filter {objectClass -eq "trustedDomain"} -Properties *
    If ($Trusts){
        Foreach ($Trust in $Trusts){
        
        Switch ($trust.TrustType) {
            1 {$trustType = "Downlevel (Windows NT Domain External)"}
            2 {$trustType = "Uplevel (AD Domain)"}
            3 {$trustType = "Kerberos Realm Trust"}
            4 {$trustType = "DCE"}
            }
        
        Switch ($trust.TrustDirection) {
            1 {$trustDirection = "One-way Inbound"}
            2 {$trustDirection = "One-way Outbound"}
            3 {$trustDirection = "Two-way"}
            }        
        
        Switch ($trust.trustAttributes) {
            1  {$trustAttributes = "Non-Transitive"}
            2  {$trustAttributes = "Uplevel clients only (Win200 or newer)"}
            4  {$trustAttributes = "External Trust"}
            8  {$trustAttributes = "Forest Trust"}
            10 {$trustAttributes = "Selective Authentication"}
            20 {$trustAttributes = "Intra-Forsest Trust"}
            }            

        $trustinfo = New-Object System.Object
        $trustinfo | Add-Member -Name DNSName -Type NoteProperty -Value $Trust.Name
        $trustinfo | Add-Member -Name Name -Type NoteProperty -Value $Trust.FlatName
        $trustinfo | Add-Member -Name Direction -Type NoteProperty -Value $TrustDirection
        $trustinfo | Add-Member -Name Type -Type NoteProperty -Value $TrustType
        $trustinfo | Add-Member -Name Attributes -Type NoteProperty -Value $TrustAttributes
        $trustinfo | Add-Member -Name Status -Type NoteProperty -Value $Trust.TrustStatus
        $trustinfo | Add-Member -Name Created -Type NoteProperty -Value $Trust.WhenCreated
        $trustinfo | Add-Member -Name Modified -Type NoteProperty -Value $Trust.WhenChanged
        $TrustReport += $trustinfo
        }
        }Else{
        "No Trusts exist`n"
        }
    
    "`nTrusts"
    "###########################################"
    $TrustReport | FT * -AutoSize
    
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
        $SiteLinkList | Add-Member -Type NoteProperty -Name Options -Value $(If (($SiteLink.Options -eq 1) -or ($SiteLink.Options -eq 5)){"Change Notification"}Else{$SiteLink.Options})
        #$SiteLinkList | Add-Member -Type NoteProperty -Name Schedule -Value $SiteLink.Schedule
        $SiteLinkList | Add-Member -Type NoteProperty -Name Schedule -Value $($site | select @{Name="Schedule";Expression={If($_.Schedule){If(($_.Schedule -Join " ").Contains("240")){"NonDefault"}Else{"24x7"}}Else{"24x7"}}}).schedule
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

    "`nSite Information"
    "###########################################"
    $SiteListReport | ft -AutoSize
    
    "`nSubnet Information"
    "###########################################"
    If ($SiteSubnetReport) {$SiteSubnetReport | ft -AutoSize} Else {"No Subnets exist`n"}
    
    "`n######### Site Link Bridge #########"
    If ($SiteLinkBridgeReport) {$SiteLinkBridgeReport | ft -AutoSize} Else {"No Site Link Bridges exist`n"}
    
    "`n######### Site Links #########"
    If ($SiteLinkReport) {$SiteLinkReport | ft -AutoSize} Else {"No Site Links exist`n"}
    }

Function Get-DNSInfo 
    {

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
    <#"`n### Primary Forward Lookup Zones ###"
    Foreach ($zone in $ZoneReport) 
        {
        $ZoneReport | ? {($_.ReverseLookup -eq $false) -and ($_.zonetype -eq "Primary") -and ($_.ZoneName -eq $Zone.ZoneName)} | Sort Server | ft Server,ZoneName,DynamicUpdate,DSIntegrated,WINSEnabled,ReplicationScope,SecureSecondaries -AutoSize
        }

    "### Primary Reverse Lookup Zones ###"
    Foreach ($zone in $ZoneReport) 
        {
        $ZoneReport | ? {($_.ReverseLookup -eq $true) -and ($_.zonetype -eq "Primary") -and ($_.ZoneName -eq $Zone.ZoneName)} |  Sort Server | ft Server,ZoneName,DynamicUpdate,DSIntegrated,WINSEnabled,ReplicationScope,SecureSecondaries -AutoSize
        }#>
    }

Function Get-GPOInfo 
    {
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
""
"Group Policy Objects that are not liked"
"#######################################"
$GPOLinkReport | ft -AutoSize

"`nGroup Policy Objects where SYSVOL"
"and Directory versions do not match"
"#######################################"
$GPOSyncReport | ft -AutoSize
}

Function Send-Report 
    {
    $To = "Campus Active Directory <activedirectory@doit.wisc.edu>" 
    $From = "Campus Active Directory <activedirectory@doit.wisc.edu>" 
    $Subject = "Active Directory AUdit Report - $($date = get-date -uformat "%Y-%m-%d")($Forest)"
    $Attachments = "C:\Rpt-ForestInfo.txt"
    $SmtpServer = "smtp.wiscmail.wisc.edu"
    $Body = " Active Directory Audit"

    Send-MailMessage `
        -To $To `
        -From $From  `
        -Subject $Subject `
        -Body $Body `
        -SmtpServer $SmtpServer `
        -Attachments $Attachments

    Remove-Item $Attachments 
}


#Get-ForestInfo
#Get-DCInfo
#Get-DSInfo
#Get-DNSInfo 
#Get-GPOInfo 
#Send-Report

"Gathering Forest Information"
Get-ForestInfo | Out-File C:\Scripts\Rpt-ForestInfo.txt -width 180
"Gathering Directory Services Information"
Get-DSInfo | Out-File -append C:\Scripts\Rpt-ForestInfo.txt -width 180
"Gathering Domain Controller Information"
Get-DCInfo | Out-File C:\Scripts\Rpt-DomainControllers.txt -width 180
"Gathering DNS Service Information"
Get-DNSInfo | Out-File C:\Scripts\Rpt-DNSInfo.txt -width 180
"Gathering Security Group Information"
Get-GroupMemberships | Out-File C:\Scripts\Rpt-Groupmemberships.txt -width 180
"Gathering Group Policy Object Information"
#Get-GPOInfo | Out-File C:\Scripts\Rpt-GPO.txt -width 180
#Send-Report