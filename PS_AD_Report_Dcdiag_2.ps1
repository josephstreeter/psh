$date = get-date -uformat "%Y-%m-%d"
$smtpServer = "smtp.wiscmail.wisc.edu"

$Repadmin = "c:\scripts\Replication-Report-"+$date+".txt"
$DomainControlers = "c:\scripts\DC-Report-"+$date+".txt"
$DirServices = "c:\scripts\Services-Report-"+$date+".txt"
$Hardware = "c:\scripts\Hardware-Report-"+$date+".txt"

$PDCE = netdom query pdc


Write-Host "############ Domain Controllers ############" > $DomainControlers
Write-Host "List of DCs." >> $DomainControlers
netdom query dc >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ Operations Masters ############" >> $DomainControlers
Write-Host "List of OMDCs." >> $DomainControlers
netdom query fsmo >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ Trusts ############" >> $DomainControlers
Write-Host "Testing External Truests" >> $DomainControlers
nltest /server:quasar.ad.wisc.edu /domain_trusts >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ DNS ############" >> $DomainControlers
Write-Host "Checks DNS Servers" >> $DomainControlers
dcdiag.exe /e /s:pulsar /test:advertising >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ Advertising ############" >> $DomainControlers
Write-Host "Checks whether each DSA is advertising itself as having the capabilities of a DSA." >> $DomainControlers
dcdiag.exe /e /s:pulsar /test:advertising >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ Connectivity ############" >> $DomainControlers
Write-Host "Tests whether DSAs are DNS registered, pingeable, and have  LDAP/RPC connectivity." >> $DomainControlers
dcdiag.exe /e /s:pulsar /test:Connectivity >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ CutoffServers ############" >> $DomainControlers
Write-Host "Check for servers that won't receive replications because its partners are down." >> $DomainControlers
dcdiag.exe /e /s:pulsar /test:CutoffServers >> $DomainControlers
Write-Host "" >> $DomainControlers

Write-Host "############ Replications ############" >> $DomainControlers
Write-Host "Checks for timely replication between directory servers." >> $DomainControlers
dcdiag.exe /e /s:pulsar /test:Replications >> $DomainControlers
Write-Host "" >> $DomainControlers




Write-Host "############ Replication Summary ############" > $Repadmin
Write-Host >> $Repadmin
repadmin /replsum >> $Repadmin
Write-Host "############ Replication Pulsar ############" >> $Repadmin
Write-Host "">> $Repadmin
repadmin /showrepl /repsto /verbose pulsar >> $Repadmin
Write-Host "############ Replication Info Quasar ############" >> $Repadmin
Write-Host "" >> $Repadmin
repadmin /showrepl /repsto /verbose quasar >> $Repadmin
Write-Host "############ Replication Magnetar ############" >> $Repadmin
Write-Host "">> $Repadmin
repadmin /showrepl /repsto /verbose magnetar >> $Repadmin


Write-Host "############ DHCP ############" > $DirServices
Write-Host "Lists authorized DHCP Servers" >> $DirServices
Netsh dhcp show server >> $DirServices
Write-Host "" >> $DirServices

Write-Host "############ Services ############" >> $DirServices
Write-Host "State of Important Services" >> $DirServices

$objForest = Get-ADForest
$GCs = $objForest.GlobalCatalogs
$colDomains = $objForest.Domains

foreach ($strDomain in $colDomains)
{
	$domain = Get-ADDomain $strDomain
	$colDCs = $domain.ReplicaDirectoryServers
foreach ($strDomain in $colDomains)
	{
	$domain = Get-ADDomain $strDomain
	$colDCs = $domain.ReplicaDirectoryServers
	foreach ($dc in $colDCs)
		{
		$eventSystem = Get-WmiObject -computer $dc win32_service -filter "Name='eventsystem'"
		$rpcss = Get-WmiObject -computer $dc win32_service -filter "Name='rpcss'"
		$ntds = Get-WmiObject -computer $dc win32_service -filter "Name='ntds'"
		$Dnscache = Get-WmiObject -computer $dc win32_service -filter "Name='Dnscache'"
		$dns = Get-WmiObject -computer $dc win32_service -filter "Name='dns'"
		$dfsr = Get-WmiObject -computer $dc win32_service -filter "Name='dfsr'"
		$IsmServ = Get-WmiObject -computer $dc win32_service -filter "Name='IsmServ'"
		$kdc = Get-WmiObject -computer $dc win32_service -filter "Name='kdc'"
		$samss = Get-WmiObject -computer $dc win32_service -filter "Name='samss'"
		$lanmanserver = Get-WmiObject -computer $dc win32_service -filter "Name='lanmanserver'"
		$lanmanworkstation = Get-WmiObject -computer $dc win32_service -filter "Name='lanmanworkstation'"
		$w32time = Get-WmiObject -computer $dc win32_service -filter "Name='w32time'"
		$netlogon = Get-WmiObject -computer $dc win32_service -filter "Name='netlogon'"
		Write-Host $dc 
		Write-Host "    COM+ Event System = 							" $eventSystem.state >> $DirServices
		Write-Host "    Remote Procedure Call (RPC) Status = 					" $rpcss.state >> $DirServices
		Write-Host "    AD Domain Services (AD DS) Status = 					" $ntds.state >> $DirServices
		Write-Host "    DNS Client Status = 							" $Dnscache.state >> $DirServices
		Write-Host "    DNS Server Status = 							" $dns.state >> $DirServices
		Write-Host "    DFS Replication Status = 							" $dfsr.state >> $DirServices
		Write-Host "    Intersite Messaging Status = 						" $IsmServ.state >> $DirServices
		Write-Host "    Kerberos Key Distribution Center Status = 				" $kdc.state >> $DirServices
		Write-Host "    Security Accounts Manager Status = 					" $samss.state >> $DirServices
		Write-Host "    Server Status = 								" $lanmanserver.state >> $DirServices
		Write-Host "    Workstaion Status = 							" $lanmanworkstation.state >> $DirServices
		Write-Host "    Windows Time Status = 							" $dns.state >> $DirServices
		Write-Host "    NETLOGON Status = 								" $IsmServ.state >> $DirServices
		}
	}}





$attRepadmin = new-object Net.Mail.Attachment($Repadmin)
$attDCDiag = new-object Net.Mail.Attachment($DomainControlers)
$attNetsh = new-object Net.Mail.Attachment($DirServices)
$attHardware = new-object Net.Mail.Attachment($Hardware)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "joseph.streeter@doit.wisc.edu"
$msg.To.Add("joseph.streeter@doit.wisc.edu")
$msg.Subject = "Active Directory Health Report "+$date
$msg.Body = "Attached is the Active Directory Health Report"
$msg.Attachments.Add($attRepadmin)
$msg.Attachments.Add($attDCDiag)
$msg.Attachments.Add($attNetsh)
$msg.Attachments.Add($attHardware)
$smtp.Send($msg)
#$att.Dispose()