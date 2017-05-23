$date = get-date -uformat "%Y-%m-%d"

$objForest = Get-ADForest
	"Forest Name: " + $objForest.name | out-file -append "$date-forest.log"
	"Forest Root Domain: " + $objForest.rootdomain | out-file -append "$date-forest.log"
	"Forest Mode: " + $objForest.forestmode | out-file -append "$date-forest.log"
	"Schema Master: " + $objForest.SchemaMaster | out-file -append "$date-forest.log"
	"Domain Naming Master: " + $objForest.DomainNamingMaster | out-file -append "$date-forest.log"
	"Global Catalog Servers:" | out-file -append "$date-forest.log"
		foreach ($objGC in $objForest.GlobalCatalogs)
			{
			"	" + $objGC | out-file -append "$date-forest.log"
			}
	"" | out-file -append "$date-forest.log"
	foreach ($strDomain in $objForest.Domains)
		{
		$objDomain = Get-ADDomain $strDomain
		"DNS Name: " + $objDomain.DNSRoot | out-file -append "$date-domain.log"
		"PDC Emulator: " + $objDomain.PDCEmulator | out-file -append "$date-domain.log"
		"DNS Name: " + $objDomain.DNSRoot | out-file -append "$date-domain.log"
		"NetBIOS Name: " + $objDomain.NetbiosName | out-file -append "$date-domain.log"
		"Domain Mode: " + $objDomain.DomainMode | out-file -append "$date-domain.log"
		"Domain SID: " + $objDomain.DomainSID | out-file -append "$date-domain.log"
		"Infrastrucure Master: " + $objDomain.InfrastructureMaster | out-file -append "$date-domain.log"
		"PDC Emulator: " + $objDomain.PDCEmulator | out-file -append "$date-domain.log"
		"RID Master: " + $objDomain.RIDMaster  | out-file -append "$date-domain.log"
		"" | out-file -append "$date-domain.log"

		"Domain Controllers:" | out-file -append "$date-domain.log"
			$colDCs = $objDomain.ReplicaDirectoryServers
			foreach ($objDC in $colDCs)
					{
					"	" + $objDC | out-file -append "$date-domain.log"
					}
		"" | out-file -append "$date-domain.log"
		"RODCs: " | out-file -append "$date-domain.log"
			foreach ($objRODC in $colDCs)
					{
					"	" + $objRODC | out-file -append "$date-domain.log"
					}
		"" | out-file -append "$date-domain.log"

			$strPDCE = $objDomain.PDCEmulator
#######################################################################
#						Functions                                     #
#######################################################################
		function DCDiag
			{
			"##### DCDIAG Tests #####" | out-file "$date-dcdiag.log"
			"DNS Test" | out-file -append "$date-dcdiag.log"
			"Checks DNS Servers." | out-file -append "$date-dcdiag.log"
			invoke-expression -Command "dcdiag.exe /test:dns /e /s:$strPDCE" | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			"Advertising Test" | out-file -append "$date-dcdiag.log"
			"Checks whether each DSA is advertising itself as having the capabilities of a DSA." | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			invoke-expression -Command "dcdiag.exe /test:advertising /e /s:$strPDCE" | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			"Connectivity Test" | out-file -append "$date-dcdiag.log"
			"Tests whether DSAs are DNS registered, pingeable, and have  LDAP/RPC connectivity." | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			invoke-expression -Command "dcdiag.exe /test:Connectivity /e /s:$strPDCE" | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			" CutoffServers Test" | out-file -append "$date-dcdiag.log"
			"Check for servers that won't receive replications because its partners are down." | out-file -append "$date-dcdiag.log"
			invoke-expression -Command "dcdiag.exe /test:CutoffServers /e /s:$strPDCE" | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			" Replications Test" | out-file -append "$date-dcdiag.log"
			"Checks for timely replication between directory servers." | out-file -append "$date-dcdiag.log"
			invoke-expression -Command "dcdiag.exe /test:Replications /e /s:$strPDCE" | out-file -append "$date-dcdiag.log"
			"" | out-file -append "$date-dcdiag.log"
			}
			
		function Replication
			{
			"##### Replication Tests #####" | out-file "$date-replication.log"
			Get-date | out-file -append "$date-replication.log"
			"####Replication Queue ####" | out-file -append "$date-replication.log"
			invoke-expression -Command "repadmin /queue" | out-file -append "$date-replication.log"
			"" | out-file -append "$date-replication.log"
			"Replication Summary" | out-file -append "$date-replication.log"
			"" | out-file -append "$date-replication.log"
			invoke-expression -Command "repadmin /replsum" | out-file -append "$date-replication.log"
			"" | out-file -append "$date-replication.log"
			
			$objDomain = Get-ADDomain
			foreach ($strDC in $objDomain.ReplicaDirectoryServers)			
				{
				"" + $strDC | out-file -append "$date-replication.log"
				invoke-expression -Command "repadmin /showrepl /repsto /verbose" | out-file -append "$date-replication.log"
				"" | out-file -append "$date-replication.log"
				}
			}
		
		function Services
			{
			"Service Information" | out-file "$date-services.log"
			Get-date | out-file -append "$date-services.log"
			$objDomain = Get-ADDomain
			foreach ($strDC in $objDomain.ReplicaDirectoryServers)
				{
				$eventSystem = Get-WmiObject -computer $strDC win32_service -filter "Name='eventsystem'"
				$rpcss = Get-WmiObject -computer $strDC win32_service -filter "Name='rpcss'"
				$ntds = Get-WmiObject -computer $strDC win32_service -filter "Name='ntds'"
				$Dnscache = Get-WmiObject -computer $strDC win32_service -filter "Name='Dnscache'"
				$dns = Get-WmiObject -computer $strDC win32_service -filter "Name='dns'"
				$dfsr = Get-WmiObject -computer $strDC win32_service -filter "Name='dfsr'"
				$IsmServ = Get-WmiObject -computer $strDC win32_service -filter "Name='IsmServ'"
				$kdc = Get-WmiObject -computer $strDC win32_service -filter "Name='kdc'"
				$samss = Get-WmiObject -computer $strDC win32_service -filter "Name='samss'"
				$lanmanserver = Get-WmiObject -computer $strDC win32_service -filter "Name='lanmanserver'"
				$lanmanworkstation = Get-WmiObject -computer $strDC win32_service -filter "Name='lanmanworkstation'"
				$w32time = Get-WmiObject -computer $strDC win32_service -filter "Name='w32time'"
				$netlogon = Get-WmiObject -computer $strDC win32_service -filter "Name='netlogon'"
				$strDC | out-file -append  "$date-services.log"
				"    COM+ Event System = " + $eventSystem.state | out-file -append "$date-services.log"
				"    Remote Procedure Call (RPC) Status = " + $rpcss.state | out-file -append "$date-services.log"
				"    AD Domain Services (AD DS) Status = " + $ntds.state | out-file -append  "$date-services.log"
				"    DNS Client Status = " + $Dnscache.state | out-file -append  "$date-services.log"
				"    DNS Server Status = " + $dns.state | out-file -append  "$date-services.log"
				"    DFS Replication Status = " + $dfsr.state | out-file -append  "$date-services.log"
				"    Intersite Messaging Status = " + $IsmServ.state | out-file -append  "$date-services.log"
				"    Kerberos Key Distribution Center Status = " + $kdc.state | out-file -append  "$date-services.log"
				"    Security Accounts Manager Status = " + $samss.state | out-file -append  "$date-services.log"
				"    Server Status = " + $lanmanserver.state | out-file -append  "$date-services.log"
				"    Workstaion Status = " + $lanmanworkstation.state | out-file -append  "$date-services.log"
				"    Windows Time Status = " + $dns.state | out-file -append  "$date-services.log"
				"    NETLOGON Status = " + $IsmServ.state | out-file -append  "$date-services.log"
				"" | out-file -append  "$date-services.log"
				}
			}
		function Hardware
			{
			"Domain Controller Information" | out-file "$date-hardware.log"
			Get-date | out-file -append "$date-hardware.log"
			$objDomain = Get-ADDomain
			foreach ($strDC in $objDomain.ReplicaDirectoryServers)
				{
				"Checking Space on $($strDC)" | out-file -append "$date-hardware.log"
				$obj_dc = Get-ADDomainController $strDC
				$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $strDC)
		
				# The NTDS Space Check
				$key_ntds = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters")
				$ntds_dir = $key_ntds.GetValue("DSA Working Directory")
				$ntds_drive = $ntds_dir.Split("\")[0]
				$ntds_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$ntds_drive'"
				$ntds_mb_space = $ntds_disk.FreeSpace / 1024 / 1024
				if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space)
					{" NTDS Partition		OK (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")" | out-file -append "$date-hardware.log"}
				if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space)
					{" NTDS Partition		Low (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")" | out-file -append "$date-hardware.log"}
				if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space_gc)
					{" NTDS Partition		OK (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")" | out-file -append "$date-hardware.log"}
				if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space_gc)
					{" NTDS Partition		Low (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")" | out-file -append "$date-hardware.log"}
		
				#The SYSVOL Space Check
				$key_sysvol = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters")
				$sysvol_dir = $key_sysvol.GetValue("SysVol")
				$sysvol_drive = $sysvol_dir.Split("\")[0]
				$sysvol_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$sysvol_drive'"
				$sysvol_mb_space = $sysvol_disk.FreeSpace / 1024 / 1024
				if ($sysvol_mb_space -gt $sysvol_space)
					{" SYSVOL Partition	OK (Disk " + $sysvol_drive + "Free Space " + $sysvol_mb_space + ")" | out-file -append "$date-hardware.log"}
				if ($sysvol_mb_space -lt $sysvol_space)
					{" SYSVOL Partition	Low (Disk " + $sysvol_drive + "Free Space " + $sysvol_mb_space + ")" | out-file -append "$date-hardware.log"}
		
				#The OS Space Check
				$key_os = $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")
				$os_dir = $key_os.GetValue("SystemRoot")
				$os_drive = $os_dir.Split("\")[0]
				$os_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$os_drive'"
				$os_mb_space = $os_disk.FreeSpace / 1024 / 1024
				if ($os_mb_space -gt $os_space)
					{" OS Partition		OK (Disk " + $os_drive + "Free Space " + $os_mb_space + ")" | out-file -append "$date-hardware.log"}
				if ($os_mb_space -lt $os_space)
					{" OS Partition		Low (Disk " + $os_drive + "Free Space " + $os_mb_space + ")" | out-file -append "$date-hardware.log"}
				}
			}
#######################################################################
#						Call Tests                                    #
#######################################################################

		DCDiag 
		Replication
		Services
		Hardware
		}

