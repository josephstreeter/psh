$threeMonths = (Get-Date).addmonths(-3)
$sixMonths = (Get-Date).addmonths(-6)
$twelveMonths = (Get-Date).addmonths(-12)
$twentyfourMonths = (Get-Date).addmonths(-24)


Write-Host "Org Accounts Not Used in Three to Six Months"
Get-ADUser -filter {(LastLogonDate -lt $threeMonths) -and (LastLogonDate -gt $sixMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize

Write-Host "Org Accounts Not Used in Six Months to One Year"
Get-ADUser -filter {(LastLogonDate -lt $sixMonths) -and (LastLogonDate -gt $twelveMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize

Write-Host "Org Accounts Not Used in One Year to Two Years"
Get-ADUser -filter {(LastLogonDate -lt $twelveMonths) -and (LastLogonDate -gt $twentyfourMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize

Write-Host "Disabled Org Accounts"
Get-ADUser -filter {(enabled -eq 'False')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize

Write-Host "Org Accounts That Have Not Been Used"
Write-Host ""
$admins = Get-ADUser -filter * -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties *
foreach ($admin in $admins)
	{
	if ($admin.lastlogonDate -eq $null)
		{
		write-host $admin.sn " " $admin.givenname " " $admin.name " " $admin.enabled " " $admin.mail
		}
	}