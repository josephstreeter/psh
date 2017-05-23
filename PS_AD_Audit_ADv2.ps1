Import-Module activedirectory
Clear-Host

Function Get-DCInfo {
$Global:Forest = Get-ADForest
$Global:RootDomain = $Forest.rootdomain
$Global:PDCE = $Domain.PDCEmulator
}

Function Get-ForestInfo {
    "Forest Information"
    "###########################################"
    "Forest Name:              " + $Forest.name
    "Forest Root Domain:       " + $Forest.rootdomain
    "Forest Mode:              " + $Forest.forestmode
    "Operations Masters:"
    "    Schema Master:        " + $Forest.SchemaMaster
    "    Domain Naming Master: " + $Forest.DomainNamingMaster
    "Global Catalog Servers:"
    foreach ($GC in $Forest.GlobalCatalogs){"	                      " + $GC}
    ""
}

Function Get-DomainInfo {
    "Domain Information"
    "###########################################"
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
		    foreach ($DC in $DCs) {"	                     " + $DC}
		    ""
	    "Read Only Domain Controllers: "
	    $RODCs = $Domain.ReadOnlyReplicaDirectoryServers
        if (-not($RODCs)) {
            "	                     none"
            } Else {
            foreach ($RODC in $RODCs){"	                     " + $RODC}
            }
        ""
        }
}

Function Get-DSInfo {
    "Directory Services Information"
    "###########################################"
    $dSHeuristics = (Get-ADObject -identity "cn=Directory Service,cn=Windows NT,cn=Services,cn=Configuration,$DN" -pr dSHeuristics).dSHeuristics
    
    "List Object Mode"
    if ((-not ($dSHeuristics)) -or ($dSHeuristics[2] -eq "0")) {
        Write-Host -ForegroundColor Yellow "Disabled"
        } Else {
        Write-Host -ForegroundColor Green "Enabled"
        }
    ""
    "Anonymous Access"
    if ((-not ($dSHeuristics)) -or ($dSHeuristics[6] -eq "0")) {
        Write-Host -ForegroundColor Green "Disabled"
        } Else {
        Write-Host -ForegroundColor Red "Enabled"
        }
    ""
}

Function Get-GroupMemberships {
    "Sensitive Group Membership"
    "###########################################"
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

    $DSA = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
    $SYSVOL = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("SysVol")
    $SYSTEM = $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion").GetValue("SystemRoot")
    $NTDS = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("Database log files path")
        
    $Files = New-Object System.Object
    $Files | Add-Member -type NoteProperty -name Server -value $DC
    $Files | Add-Member -type NoteProperty -name DSA -value $DSA
    $Files | Add-Member -type NoteProperty -name SYSVOL -value $SYSVOL
    $Files | Add-Member -type NoteProperty -name SYSTEM -value $SYSTEM
    $Files | Add-Member -type NoteProperty -name NTDS -value $NTDS
    $FilesReport += $Files 
    }

    "Domain Controller Security Policy"
    "###########################################"
    "Domain controller: LDAP server signing requirements"
    "Network security: LDAP client signing requirements"
    "Network security: Do not store LAN Manager hash value on next password change"
    "Network security: LAN Manager authentication level"
    "###########################################"
    $LDAPReport | sort server | ft -AutoSize

    "SYSVOL, Database, and Log File Locations"
    "###########################################"
    $FilesReport | sort server | ft -AutoSize
}

Function Get-DNSInfo {
    "DNS Server Information"
    "###########################################"
    $ScavengeReport = @()
    $RecurReport = @()
    $ZoneReport = @()
    $ZoneScavReport = @()
    $CacheReport = @()
    $ForwardReport = @()
    $ServerReport = @()

    Foreach ($DC in $DCs) {
        $DNSSettings = Get-DnsServer -computer $DC -WarningAction SilentlyContinue

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

        $ScavengeProp = New-Object System.Object
        $ScavengeProp | Add-Member -type NoteProperty -name Server -value $DC
        $ScavengeProp | Add-Member -type NoteProperty -name LastScavengeTime -value $DNSSettings.ServerScavenging.LastScavengeTime
        $ScavengeProp | Add-Member -type NoteProperty -name NoRefreshInterval -value $DNSSettings.ServerScavenging.NoRefreshInterval 
        $ScavengeProp | Add-Member -type NoteProperty -name ScavengingInterval -value $DNSSettings.ServerScavenging.ScavengingInterval
        $ScavengeProp | Add-Member -type NoteProperty -name ScavengingState -value $DNSSettings.ServerScavenging.ScavengingState 
        $ScavengeReport += $ScavengeProp

        $RecurProp = New-Object System.Object
        $RecurProp | Add-Member -type NoteProperty -name Server -value $DC
        $RecurProp | Add-Member -type NoteProperty -name RecursionEnable -value $DNSSettings.ServerRecursion.Enable
        $RecurProp | Add-Member -type NoteProperty -name AdditionalTimeout -value $DNSSettings.ServerRecursion.AdditionalTimeout
        $RecurProp | Add-Member -type NoteProperty -name RetryInterval -value $DNSSettings.ServerRecursion.RetryInterval
        $RecurProp | Add-Member -type NoteProperty -name Timeout -value $DNSSettings.ServerRecursion.Timeout
        $RecurProp | Add-Member -type NoteProperty -name SecureResponse  -value $DNSSettings.ServerRecursion.SecureResponse 
        $RecurReport += $RecurProp

        $CacheProp = New-Object System.Object
        $CacheProp | Add-Member -type NoteProperty -name Server -value $DC
        $CacheProp | Add-Member -type NoteProperty -name MaxNegTTL -value $DNSSettings.ServerCache.MaxNegativeTtl
        $CacheProp | Add-Member -type NoteProperty -name EnablePollProt -value $DNSSettings.ServerCache.EnablePollutionProtection
        $CacheReport += $CacheProp

        $ForwardProp = New-Object System.Object
        $ForwardProp | Add-Member -type NoteProperty -name Server -value $DC
        $ForwardProp | Add-Member -type NoteProperty -name IPAddress -value $DNSSettings.ServerForwarder.IPAddress
        $ForwardProp | Add-Member -type NoteProperty -name UseRootHint -value $DNSSettings.ServerForwarder.UseRootHint
        $ForwardProp | Add-Member -type NoteProperty -name Timeout -value $DNSSettings.ServerForwarder.Timeout
        $ForwardReport += $ForwardProp 

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

    Foreach ($Zone in $DNSSettings.ServerZoneAging) {
        $ZoneScav = New-Object System.Object
        $ZoneScav | Add-Member -type NoteProperty -name Server -value $DC
        $ZoneScav | Add-Member -type NoteProperty -name ZoneName -value $Zone.ZoneName
        $ZoneScav | Add-Member -type NoteProperty -name AgingEnabled -value $Zone.AgingEnabled
        $ZoneScav | Add-Member -type NoteProperty -name AvailForScavengeTime -value $Zone.AvailForScavengeTime
        $ZoneScav | Add-Member -type NoteProperty -name RefreshInterval -value $Zone.RefreshInterval
        $ZoneScav | Add-Member -type NoteProperty -name NoRefreshInterval -value $Zone.NoRefreshInterval
        $ZoneScav | Add-Member -type NoteProperty -name ScavengeServers -value $Zone.ScavengeServers
        $ZoneScavReport += $ZoneScav
    }
}

    "######### Server Settings #########"
    $ServerReport | ft -AutoSize
    "######### Scavenging Settings #########"
    $ScavengeReport | ft -AutoSize
    "######### Recusive Settings #########"
    $RecurReport | ft -AutoSize
    "######### Zone Scavenging Settings #########"
    $ZoneScavReport | sort ZoneName, server | ft -AutoSize
    "######### Zone Settings #########"
    $ZoneReport | sort ZoneName, server | ft -AutoSize
    "######### Cache Settings #########"
    $CacheReport | ft -AutoSize
    "######### Forwarder Settings #########"
    $ForwardReport | sort ZoneName, server | ft -AutoSize
}

Function Get-Interfaces {
    "Network Interface Properties"
    "###########################################"
    $IfReport = @()
    Foreach ($DC in (Get-ADDomainController -Filter *)) {
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
        }  
    $IfReport | sort server | ft -AutoSize
}

Get-DCInfo
Get-ForestInfo
Get-DomainInfo
Get-DSInfo
Get-GroupMemberships
Get-DomainControllers
Get-DNSInfo
Get-Interfaces