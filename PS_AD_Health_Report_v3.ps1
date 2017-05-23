###############################################################
#		    Configure Powershell                              #
###############################################################

# Check PowerShell version
If ($(get-host).version.major -lt 2) {
    Write-Host -ForegroundColor Red "Requires PowerShell Version 2 or Higher"
    }

# Import Active Directory PowerShell Module
import-module activedirectory

#######################################################################
#			Set Variables                                 #
#######################################################################

$date = get-date -uformat "%Y-%m-%d"
$startDate = (Get-Date).adddays(-1) #Sets the start date for Event Logs as yesterday
$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "activedirectory@doit.wisc.edu"
$mailto = "joseph.streeter@doit.wisc.edu"

$Repadmin = "C:\scripts\"+$date+"-01-Replication-Report.log"
$DomainControlers = "C:\scripts\"+$date+"-02-DCDIAG-Report.log"
$DirServices = "C:\scripts\"+$date+"-03-Services-Report.log"
$Hardware = "C:\scripts\"+$date+"-11-Hardware-Report.log"
$Forest = "C:\scripts\"+$date+"-12-Forest-Report.log"
$SystemEvents = "C:\scripts\"+$date+"-04-Events-Sys-Report.log"
$ApplicationEvents = "C:\scripts\"+$date+"-05-Events-App-Report.log"
$SecurityEvents = "C:\scripts\"+$date+"-06-Events-Sec-Report.log"
$dnsevents = "C:\scripts\"+$date+"-07-Events-DNS-Report.log"
$directoryevents = "C:\scripts\"+$date+"-08-Events-DS-Report.log"
$frsevents = "C:\scripts\"+$date+"-09-Events-FRS-Report.log"
$dfsevents = "C:\scripts\"+$date+"-10-Events-DFS-Report.log"

		
$objForest = Get-ADForest
	$strRootDomain = $objForest.rootdomain
	$objDomain = Get-ADDomain $strRootDomain
	$Global:strPDCE = $objDomain.PDCEmulator

#######################################################################
#		 Get Active Directory Information                     #
#######################################################################

function Forest
	{
	"################## AD Forest Information ##########################"
	""
	$date
	""
	$objForest = Get-ADForest
	"Forest Name: " + $objForest.name
	"Forest Root Domain: " + $objForest.rootdomain
	"Forest Mode: " + $objForest.forestmode
	"Schema Master: " + $objForest.SchemaMaster
	"Domain Naming Master: " + $objForest.DomainNamingMaster
	"Global Catalog Servers:"
		foreach ($objGC in $objForest.GlobalCatalogs)
			{
			"	" + $objGC
			}
	""
	"################## AD Domain Information ##########################"
	""
	foreach ($strDomain in $objForest.Domains)
		{
		$objDomain = Get-ADDomain $strDomain
		"DNS Name: " + $objDomain.DNSRoot
		"PDC Emulator: " + $objDomain.PDCEmulator
		"NetBIOS Name: " + $objDomain.NetbiosName
		"Domain Mode: " + $objDomain.DomainMode
		"Domain SID: " + $objDomain.DomainSID
		"Infrastrucure Master: " + $objDomain.InfrastructureMaster
		"PDC Emulator: " + $objDomain.PDCEmulator
		"RID Master: " + $objDomain.RIDMaster 
		""

		"Domain Controllers:"
			$colDCs = $objDomain.ReplicaDirectoryServers
			foreach ($objDC in $colDCs)
					{
					"	" + $objDC
					}
		""
		"RODCs: "
			$colRODCs = $objDomain.ReadOnlyReplicaDirectoryServers
			foreach ($objRODC in $colRODCs)
					{
					"	" + $objRODC
					}
		""
		}
	}
	
function DCDiag
	{
	"#################### DCDIAG Tests ##########################"
	""
	$date
	""
	"#################### All DCDIAG Errors #####################"
	"Lists DCDiag Errors Only"
	""
	"############################################################"
	invoke-expression -Command "dcdiag.exe /v /q /e /s:$Global:strPDCE /skip:systemlog"
	
	"################# Complete DCDIAG Test ##################"
	"The complete DCDIAG test results"
	""
	"############################################################"
	""
	invoke-expression -Command "dcdiag.exe /v /e /s:$Global:strPDCE /skip:systemlog"
	}
		
function Replication
	{
	"########### Repadmin Replication Test #####################"
	""
	$date
	""
	"########### Replication Queue #####################"
	$objDomain = Get-ADDomain
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)			
		{
		"" + $strDC
		""
		invoke-expression -Command "repadmin /queue $strDC"
		""
		}
	""
	""
	"########### Replication Summary #####################"
	""
	invoke-expression -Command "repadmin /replsum"
	""
	""
	"############# Replication Verbose Summary #############"
	""			
	$objDomain = Get-ADDomain
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)			
		{
		"" + $strDC
		""
		invoke-expression -Command "repadmin /showrepl $strDC"
		""
		}
	}
		
function Services
	{
	"############### Critical Services ###############"
	""
	$date
	""
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
		$strDC
		"    COM+ Event System = " + $eventSystem.state
		"    Remote Procedure Call (RPC) Status = " + $rpcss.state
		"    AD Domain Services (AD DS) Status = " + $ntds.state
		"    DNS Client Status = " + $Dnscache.state
		"    DNS Server Status = " + $dns.state
		"    DFS Replication Status = " + $dfsr.state
		"    Intersite Messaging Status = " + $IsmServ.state
		"    Kerberos Key Distribution Center Status = " + $kdc.state
		"    Security Accounts Manager Status = " + $samss.state
		"    Server Status = " + $lanmanserver.state
		"    Workstaion Status = " + $lanmanworkstation.state
		"    Windows Time Status = " + $dns.state
		"    NETLOGON Status = " + $IsmServ.state
		""
		}
	}

function Hardware
	{
	"############# Hardware Information #############"
	""
	$date
	""
	"############# Hard Drive Space #############"
	""
	$objDomain = Get-ADDomain
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)
		{
		"Checking Space on $($strDC)"
		$obj_dc = Get-ADDomainController $strDC
		$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $strDC)

		# The NTDS Space Check
		$key_ntds = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters")
		$ntds_dir = $key_ntds.GetValue("DSA Working Directory")
		$ntds_drive = $ntds_dir.Split("\")[0]
		$ntds_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$ntds_drive'"
		$ntds_mb_space = $ntds_disk.FreeSpace / 1024 / 1024
		if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space)
			{" NTDS Partition		OK (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")"}
		if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space)
			{" NTDS Partition		Low (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")"}
		if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space_gc)
			{" NTDS Partition		OK (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")"}
		if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space_gc)
			{" NTDS Partition		Low (Disk " + $ntds_drive + "Free Space " + $ntds_mb_space + ")"}
	
		#The SYSVOL Space Check
		$key_sysvol = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters")
		$sysvol_dir = $key_sysvol.GetValue("SysVol")
		$sysvol_drive = $sysvol_dir.Split("\")[0]
		$sysvol_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$sysvol_drive'"
		$sysvol_mb_space = $sysvol_disk.FreeSpace / 1024 / 1024
		if ($sysvol_mb_space -gt $sysvol_space)
			{" SYSVOL Partition	OK (Disk " + $sysvol_drive + "Free Space " + $sysvol_mb_space + ")"}
		if ($sysvol_mb_space -lt $sysvol_space)
			{" SYSVOL Partition	Low (Disk " + $sysvol_drive + "Free Space " + $sysvol_mb_space + ")"}

		#The OS Space Check
		$key_os = $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")
		$os_dir = $key_os.GetValue("SystemRoot")
		$os_drive = $os_dir.Split("\")[0]
		$os_disk = Get-WmiObject -ComputerName $strDC -Class Win32_LogicalDisk -Filter "DeviceID = '$os_drive'"
		$os_mb_space = $os_disk.FreeSpace / 1024 / 1024
		if ($os_mb_space -gt $os_space)
			{" OS Partition		OK (Disk " + $os_drive + "Free Space " + $os_mb_space + ")"}
		if ($os_mb_space -lt $os_space)
			{" OS Partition		Low (Disk " + $os_drive + "Free Space " + $os_mb_space + ")"}
		""
		}
	}

function systemevents
	{
	"System Events"
	get-date -uformat "%d-%m-%Y"
	$block = @("3221227472", "3221229571", "1501", "1502", "7040", "7036", "5805", "5723", "5722", "5719", "2000", "10029")

	$objDomain = Get-ADDomain

	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC 
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='system';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}

function applicationevents
	{
	$block = @("0000", "0001", "8224")

	$objDomain = Get-ADDomain
	"Application Events"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC 
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='application';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}
		
function securityevents
	{
	$block = @("0000", "0001")

	$objDomain = Get-ADDomain
	"Security Event Logs"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC		
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='security';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}
	
function dnsevents
	{
	$block = @("0000", "0001")

	$objDomain = Get-ADDomain
	"DNS Service Event Logs"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC		
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='dns server';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}
	
function directoryevents
	{
	$block = @("701", "1213", "1216", "1317", "1535", "2041", "2889")

	$objDomain = Get-ADDomain
	"Directory Service Event Logs"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC		
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='directory service';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}

function frsevents
	{
	$block = @("0000", "0001")

	$objDomain = Get-ADDomain
	"FRS Service Event Logs"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC		
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='file replication service';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}

function dfsevents
	{
	$block = @("0000", "0001")

	$objDomain = Get-ADDomain
	"DFS Service Event Logs"
	get-date -uformat "%d-%m-%Y"
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)	
		{
		"#########################"
		$strDC		
		"#########################"
		$systemEvents = Get-WinEvent -computername $strDC -FilterHashtable @{Logname='dfs replication';StartTime=$startDate}

		foreach ($Event in $systemEvents)
			{
			if (($block -notcontains $Event.id))
				{
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
				}
			}
		}
	}
#######################################################################
#			Call Tests                                    #
#######################################################################

		DCDiag | out-file $DomainControlers
		Replication | out-file $Repadmin 
		Services | out-file $DirServices
		Hardware | out-file $Hardware
		Forest | out-file $Forest
		systemevents | out-file $SystemEvents
		applicationevents | out-file $ApplicationEvents
		#securityevents | out-file $SecurityEvents
		dnsevents | Out-File $dnsevents
		directoryevents | Out-File $directoryevents
		frsevents | Out-File $frsevents
		dfsevents | Out-File $dfsevents
		
#######################################################################
#			Send Message                                  #
#######################################################################

$attRepadmin = new-object Net.Mail.Attachment($Repadmin)
$attDCDiag = new-object Net.Mail.Attachment($DomainControlers)
$attNetsh = new-object Net.Mail.Attachment($DirServices)
$attHardware = new-object Net.Mail.Attachment($Hardware)
$attForest = new-object Net.Mail.Attachment($Forest)
$attSystemEvents = new-object Net.Mail.Attachment($SystemEvents)
$attApplicationEvents = new-object Net.Mail.Attachment($ApplicationEvents)
#$attSecurityEvents = new-object Net.Mail.Attachment($SecurityEvents)
$attDnsevents = new-object Net.Mail.Attachment($dnsevents)
$attDirectoryevents = new-object Net.Mail.Attachment($directoryevents)
$attFrsevents = new-object Net.Mail.Attachment($frsevents)
$attDfsevents = new-object Net.Mail.Attachment($dfsevents)

$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = $mailFrom
$msg.To.Add($mailTo)
$msg.Subject = "Active Directory Health Report "+$date+" ("+$strRootDomain+")"
$msg.Body = "Attached is the Active Directory Health Report"

$msg.Attachments.Add($attRepadmin)
$msg.Attachments.Add($attDCDiag)
$msg.Attachments.Add($attNetsh)
$msg.Attachments.Add($attHardware)
$msg.Attachments.Add($attForest)
$msg.Attachments.Add($attSystemEvents)
$msg.Attachments.Add($attApplicationEvents)
#$msg.Attachments.Add($attSecurityEvents)
$msg.Attachments.Add($attDnsevents)
$msg.Attachments.Add($attDirectoryevents)
$msg.Attachments.Add($attFrsevents)
$msg.Attachments.Add($attDfsevents)

$smtp.Send($msg)

$attRepadmin.Dispose()
$attDCDiag.Dispose()
$attNetsh.Dispose()
$attHardware.Dispose()
$attForest.Dispose()
$attSystemEvents.Dispose()
$attApplicationEvents.Dispose()
#$attSecurityEvents.Dispose()
$attDnsevents.Dispose()
$attDirectoryevents.Dispose()
$attFrsevents.Dispose()
$attDfsevents.Dispose()