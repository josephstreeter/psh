$date = (get-date).ToShortDateString().Replace("/","-")
$file = "Stale-User-Report.txt"
$rpt = ".\" + $date + "-" + $file

$Domain = (get-addomain).DistinguishedName
$Base = "ou=orgUnits"
$dn = $Base + "," + $Domain

Write-Host "Stale User Report" | Out-File $rpt

$OUs = Get-ADOrganizationalUnit -f * -pr * -searchbase $dn -SearchScope OneLevel

foreach ($OU in $OUs)
  {
  $Users = Get-ADUser -f * -pr name, lastlogondate, description -searchbase $OU | ? {$_.lastlogondate -le (get-date).adddays(-365) -and ($_.lastlogondate -ne $NULL)} 
  If ($Users.count -gt 1)
    {
	$OU.description + " (" + $OU.Name + ")" | Out-File -Append $rpt
	$Users | sort lastlogondate| ft name, lastlogondate, description -auto | Out-File -Append $rpt
	}
  }