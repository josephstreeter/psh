$date = (get-date).ToShortDateString().Replace("/","-")
$file = "Stale-Computer-Report.txt"
$rpt = ".\" + $date + "-" + $file

$Domain = (get-addomain).DistinguishedName
$Base = "ou=orgUnits"
$dn = $Base + "," + $Domain

Write-Host "Stale Computer Report" | Out-File $rpt

$OUs = Get-ADOrganizationalUnit -f * -pr * -searchbase $dn -SearchScope OneLevel

foreach ($OU in $OUs)
  {
  $Computers = Get-ADComputer -f * -pr name, lastlogondate, description, operatingsystem, operatingsystemversion -searchbase $OU | ? {$_.lastlogondate -le (get-date).adddays(-365) -and ($_.lastlogondate -ne $NULL)} 
  If ($Computers.count -gt 1)
    {
	$OU.description + " (" + $OU.Name + ")" | Out-File -Append $rpt
	$Computers | sort lastlogondate| ft name, lastlogondate, description, operatingsystem, operatingsystemversion -auto | Out-File -Append $rpt
	}
  }