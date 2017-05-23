$objDomain = Get-ADDomain
	foreach ($strDC in $objDomain.ReplicaDirectoryServers)
		{
		write-host $strDC
		Write-Host "Application"
		Get-EventLog -computername $strDC -log "application" -entrytype Error -after (get-date).addhours(-24)
		Write-Host "Directory Services"
		Get-EventLog -computername $strDC -log "Directory Service" -entrytype Error -after (get-date).addhours(-24)
		Write-Host "DNS Server"
		Get-EventLog -computername $strDC -log "DNS Server" -entrytype Error -after (get-date).addhours(-24)
		Write-Host "FRS"
		Get-EventLog -computername $strDC -log "File Replication Service" -entrytype Error -after (get-date).addhours(-24)
		#Write-Host "Security"
		#Get-EventLog -computername $strDC -log "Security" -entrytype FailureAudit -after (get-date).addhours(-24)
		Write-Host "System"
		Get-EventLog -computername $strDC -log "System" -entrytype Error -after (get-date).addhours(-24)
		}