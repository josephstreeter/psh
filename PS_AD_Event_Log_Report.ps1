$startDate = (Get-Date).adddays(-1)

function systemevents
	{
	"System Events"
	get-date -uformat "%d-%m-%Y"
	$block = @("3221227472", "3221229571", "7036", "5805", "5723", "5722", "5719", "2000")

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
	$block = @("0000", "0001")

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
	$block = @("1535", "2041")

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
systemevents | Out-File "c:\scripts\test-system.log"
applicationevents | Out-File "c:\scripts\test-app.log"
#securityevents | Out-File "c:\scripts\test-security.log"
dnsevents | Out-File "c:\scripts\test-dns.log"
directoryevents | Out-File "c:\scripts\test-directory.log"
frsevents | Out-File "c:\scripts\test-frs.log"
dfsevents | Out-File "c:\scripts\test-dfs.log"