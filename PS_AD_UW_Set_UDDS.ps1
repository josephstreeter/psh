$Domain = (get-addomain).DistinguishedName
$Base = "ou=orgUnits"
$dn = $Base + "," + $Domain

$OUs = Get-ADOrganizationalUnit -f * -pr * -searchbase $dn -SearchScope OneLevel | Select-Object name, admindescription

foreach ($OU in $OUs) 
	{
	#$Org = 
	$Org = $OU.name+"-OU Admins-gs"
	#Get-ADGroup -Filter {name -eq $org} | %{Set-ADGroup $_ -replace @{admindescription=$OU.admindescription}}
	$grp = Get-ADGroup -Filter {name -eq $org} -Properties *
	$grp.name + " " + $grp.admindescription + " " + $OU.name + " " + $OU.admindescription
	}