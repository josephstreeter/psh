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
    "Forest Name: " + $Forest.name
    "Forest Root Domain: " + $Forest.rootdomain
    "Forest Mode: " + $Forest.forestmode
    "Operations Masters:"
    "    Schema Master:        " + $Forest.SchemaMaster
    "    Domain Naming Master: " + $Forest.DomainNamingMaster
    "Global Catalog Servers:"
    foreach ($GC in $Forest.GlobalCatalogs){
        "	" + $GC
    	}
    ""
}

Function Get-DomainInfo {
    "Domain Information"
    "###########################################"
    foreach ($child in $Forest.Domains) {
        $Global:Domain = Get-ADDomain $child
        $Global:DN = $domain.DistinguishedName
    	"DNS Name: " + $Domain.DNSRoot
        "NetBIOS Name: " + $Domain.NetbiosName
    	"Domain Mode: " + $Domain.DomainMode
    	"Domain SID: " + $Domain.DomainSID
        "Operations Masters:"
	    "   PDC Emulator:         " + $Domain.PDCEmulator
	    "   Infrastrucure Master: " + $Domain.InfrastructureMaster
	    "   RID Master:           " + $Domain.RIDMaster 
	    ""
        "Domain Controllers:"
    	    $DCs = $Domain.ReplicaDirectoryServers
		    foreach ($DC in $DCs) {
		        "	" + $DC
		    }
		    ""
	    "RODCs: "
	    $RODCs = $Domain.ReadOnlyReplicaDirectoryServers
        if (-not($RODCs)) {
            "    none"
            } Else {
            foreach ($RODC in $RODCs){
	            "	" + $RODC
	            }
            }
        ""
        Get-DomainControllers
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
    "Domain Controllers"
    "###########################################"
    Foreach ($DC in $DCs) {
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $DC)

    "___________________________________________"
    (gwmi -Class win32_operatingsystem -ComputerName $DC).CSName + " (" + (gwmi -Class win32_operatingsystem -ComputerName $DC).caption.trim() + ")"
    ""
    "Domain controller: LDAP server signing requirements"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("ldapserverintegrity")))
        {
        "0" {Write-Host -ForegroundColor Red "None"}
        "1" {Write-Host -ForegroundColor Red "Negotiate"}
        "2" {Write-Host -ForegroundColor Green "Require Signing"}
        default {Write-Host -ForegroundColor Yellow "Unknown"}
        }

    "Network security: LDAP client signing requirements"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\LDAP").GetValue("LDAPClientIntegrity")))
        {
        "0" {Write-Host -ForegroundColor Red "None"}
        "1" {Write-Host -ForegroundColor Yellow "Negotiate Signing"}
        "2" {Write-Host -ForegroundColor Green "Require Signing"}
        default {Write-Host -ForegroundColor Yellow "Unknown"}
        }

    "Network security: Do not store LAN Manager hash value on next password change"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("NoLMHash")))
        {
        "0" {Write-Host -ForegroundColor Red "Disabled"}
        "1" {Write-Host -ForegroundColor Green "Enabled"}
        default {Write-Host -ForegroundColor Yellow "Unknown"}
        }

    "Network security: LAN Manager authentication level"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("LmCompatibilityLevel")))
        {
        "0" {Write-Host -ForegroundColor Red "Send LM & NTLM responses"}
        "1" {Write-Host -ForegroundColor Red "Send LM & NTLM - use NTLMv2 session security if negotiated"}
        "2" {Write-Host -ForegroundColor Red "Send NTLM response only"}
        "3" {Write-Host -ForegroundColor Red "Send NTLMv2 response only"}
        "4" {Write-Host -ForegroundColor Yellow "Send NTLMv2 response only\refuse LM"}
        "5" {Write-Host -ForegroundColor Green "Send NTLMv2 response only\refuse LM & NTLM"}
        default {Write-Host -ForegroundColor Yellow "Unknown"}
        }
    ""
    "SYSVOL, Database, and Log File Locations"

    $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
    $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("SysVol")
    $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion").GetValue("SystemRoot")
    $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("Database log files path")
    }
}

Function Get-DNSInfo {
"DNS Server Information"
"###########################################"
    $ScavengeReport = @()
    $RecurReport = @()
    $ZoneReport = @()
    $CacheReport = @()
    $ForwardReport = @()
    $ServerReport = @()

    Foreach ($DC in $DCs) {
        ""
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
    }

    Foreach ($DC in $DCs) {

        Foreach ($Zone in ($DNSSettings.ServerZone | ? {$_.IsAutoCreated -eq $false})) {
            $ZoneProp = New-Object System.Object
            $ZoneProp | Add-Member -type NoteProperty -name Server -value $DC
            $ZoneProp | Add-Member -type NoteProperty -name ZoneName -value $Zone.ZoneName
            $ZoneProp | Add-Member -type NoteProperty -name ZoneType -value $Zone.ZoneType
            $ZoneProp | Add-Member -type NoteProperty -name DynamicUpdate -value $Zone.DynamicUpdate
            $ZoneProp | Add-Member -type NoteProperty -name DSIntegrated -value $Zone.IsDsIntegrated
            $ZoneProp | Add-Member -type NoteProperty -name ReverseLookup -value $Zone.IsReverseLookupZone
            $ZoneProp | Add-Member -type NoteProperty -name WINSEnabled -value $Zone.IsWinsEnabled
            $ZoneProp | Add-Member -type NoteProperty -name ReplicationScope -value $Zone.ReplicationScope
            $ZoneProp | Add-Member -type NoteProperty -name SecureSecondaries -value $Zone.SecureSecondaries
            $ZoneReport += $ZoneProp
        }
    }
    "######### Server Settings #########"
    $ServerReport | ft -AutoSize
    "######### Scavenging Settings #########"
    $ScavengeReport | ft -AutoSize
    "######### Recusive Settings #########"
    $RecurReport | ft -AutoSize
    "######### Zone Scavenging Settings #########"
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
Get-DNSInfo
Get-Interfaces