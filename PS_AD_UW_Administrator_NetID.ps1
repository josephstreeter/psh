$ouadmins = Get-ADUser -filter * -SearchBase 'OU=OU-Admins,OU=AdminAccounts,OU=ManageDomain,DC=ad,DC=wisc,DC=edu'

foreach ($ouAdmin in $ouAdmins)
	{
	$NetID = $ouAdmin.name.split("-")
	$username = $NetID[0]
	$user = Get-ADUser -filter {cn -eq $username} -SearchBase 'OU=NetID,OU=Wisc,DC=ad,DC=wisc,DC=edu' -Properties *
	write-host $user.name"		"$user.mail"		"$ouAdmin.name"			"$ouAdmin.mail
	}