Import-Module activedirectory

Clear-Host

    $Global:Forest = Get-ADForest
    $Global:RootDomain = $Forest.rootdomain
    $Global:PDCE = $Domain.PDCEmulator

    "<h2>Forest Information</h2>"
    "<hr />"
    "<p><b>Forest Name:</b> " + $Forest.name +"<br />"
    "<b>Forest Root Domain:</b> " + $Forest.rootdomain +"<br />"
    "<b>Forest Mode:</b> " + $Forest.forestmode +"<br />"
    "<b>Operations Masters:</b><br />"
    "<b>    Schema Master:</b>        " + $Forest.SchemaMaster +"<br />"
    "<b>    Domain Naming Master:</b> " + $Forest.DomainNamingMaster +"<br />"
    "<b>Global Catalog Servers:</b><br />"
    "<ul>"
    foreach ($GC in $Forest.GlobalCatalogs){
        "<li>" + $GC + "</li>"
    	}
    "</ul>"
      "<h2>Domain Information</h2>"
    "<hr />"
    foreach ($child in $Forest.Domains) {
        $Domain = Get-ADDomain $child
        $DN = $domain.DistinguishedName
    	"<p><b>DNS Name:</b> " + $Domain.DNSRoot +"<br />"
        "<b>NetBIOS Name:</b> " + $Domain.NetbiosName +"<br />"
    	"<b>Domain Mode:</b> " + $Domain.DomainMode +"<br />"
    	"<b>Domain SID:</b> " + $Domain.DomainSID +"<br />"
        "<b>Operations Masters:</b><br />"
	    "<b>&nbsp;PDC Emulator:</b>         " + $Domain.PDCEmulator +"<br />"
	    "<b>&nbsp;Infrastrucure Master:</b> " + $Domain.InfrastructureMaster +"<br />"
	    "<b>&nbsp;RID Master:</b>           " + $Domain.RIDMaster +"</p>"
	    "<br />"
        "<b>Domain Controllers:</b>"
    	$DCs = $Domain.ReplicaDirectoryServers
        "<ul>"
		    foreach ($DC in $DCs) {
		        "<li>" + $DC + "</li>"
		    }
		    "</ul>"
	    "RODCs: "
        "<ul>"
	    $RODCs = $Domain.ReadOnlyReplicaDirectoryServers
        if (-not($RODCs)) {
            "    none"
            } Else {
            foreach ($RODC in $RODCs){
	            "<li>" + $RODC + "</li>"
	            }
            }
        "</ul>"
        }
        "</p>"
    "<h2>Directory Services Information</h2>"
    "<hr />"
    $dSHeuristics = (Get-ADObject -identity "cn=Directory Service,cn=Windows NT,cn=Services,cn=Configuration,$DN" -pr dSHeuristics).dSHeuristics
    "<p>List Object Mode</p>"
    if ((-not ($dSHeuristics)) -or ($dSHeuristics[2] -eq "0")) {
        '<p><font color="yellow">Disabled</font></p>'
        } Else {
        '<p><font color="Green">Enabled</font></p>'
        }
    "<p>Anonymous Access</p>"
    if ((-not ($dSHeuristics)) -or ($dSHeuristics[6] -eq "0")) {
        '<p><font color="green">Disabled</font></p>'
        } Else {
        '<p><font color="red">Enabled"</font></p>'
        }

    "<h2>Sensitive Group Membership</h2>"
    "<hr />"
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
        $group + " " + (Get-ADGroupMember $group).count
        }
    "<h2>Domain Controller Security</h2>"
    "<hr />"
    Foreach ($DC in $DCs) {
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $DC)
    (gwmi -Class win32_operatingsystem -ComputerName $DC).CSName + " (" + (gwmi -Class win32_operatingsystem -ComputerName $DC).caption.trim() + ")"
"<p>___________________________________________</p>"
    "<h4>Domain controller: LDAP server signing requirements</h4>"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("ldapserverintegrity")))
        {
        "0" {'<p><font color="red">None</font></p>'}
        "1" {'<p><font color="red">Negotiate</font></p>'}
        "2" {'<p><font color="green">Require Signing</font></p>'}
        default {'<p><font color="yellow">Unknown</font></p>'}
        }

    "Network security: LDAP client signing requirements"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Services\LDAP").GetValue("LDAPClientIntegrity")))
        {
        "0" {'<p><font color="red">None</font></p>'}
        "1" {'<p><font color="green">Require Signing</font></p>'}
        default {'<p><font color="yellow">Unknown</font></p>'}
        }

    "Network security: Do not store LAN Manager hash value on next password change"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("NoLMHash")))
        {
        "0" {'<p><font color="red">Disabled</font></p>'}
        "1" {'<p><font color="green">Enabled</font></p>'}
        default {'<p><font color="yellow">Unknown</font></p>'}
        }

    "Network security: LAN Manager authentication level"
    Switch ($($reg.OpenSubKey("System\CurrentControlSet\Control\Lsa").GetValue("LmCompatibilityLevel")))
        {
        "0" {'<p><font color="red">Send LM & NTLM responses</font></p>'}
        "1" {'<p><font color="red">Send LM & NTLM - use NTLMv2 session security if negotiated</font></p>'}
        "2" {'<p><font color="red">Send NTLM response only</font></p>'}
        "3" {'<p><font color="red">Send NTLMv2 response only</font></p>'}
        "4" {'<p><font color="yellow">Send NTLMv2 response only\refuse LM</font></p>'}
        "5" {'<p><font color="green">Send NTLMv2 response only\refuse LM & NTLM</font></p>'}
        default {'<p><font color="yellow">Unknown</font></p>'}
        }
    ""
    "SYSVOL, Database, and Log File Locations"

    "<ul><li>" + $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("DSA Working Directory") + "</li>"
    "<li>" + $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("SysVol") + "</li>"
    "<li>" + $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion").GetValue("SystemRoot") + "</li>"
    "<li>" + $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("Database log files path") + "</li></ul>"
    }