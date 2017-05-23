$objForest = Get-ADForest
$GCs = $objForest.GlobalCatalogs
$colDomains = $objForest.Domains

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
		Write-Host "    COM+ Event System = 							" $eventSystem.state
		Write-Host "    Remote Procedure Call (RPC) Status = 					" $rpcss.state
		Write-Host "    AD Domain Services (AD DS) Status = 					" $ntds.state
		Write-Host "    DNS Client Status = 							" $Dnscache.state
		Write-Host "    DNS Server Status = 							" $dns.state
		Write-Host "    DFS Replication Status = 							" $dfsr.state
		Write-Host "    Intersite Messaging Status = 						" $IsmServ.state
		Write-Host "    Kerberos Key Distribution Center Status = 				" $kdc.state
		Write-Host "    Security Accounts Manager Status = 					" $samss.state
		Write-Host "    Server Status = 								" $lanmanserver.state
		Write-Host "    Workstaion Status = 							" $lanmanworkstation.state
		Write-Host "    Windows Time Status = 							" $dns.state
		Write-Host "    NETLOGON Status = 								" $IsmServ.state
		}
	}