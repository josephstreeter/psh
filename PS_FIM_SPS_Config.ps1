$t = Get-SPWebTemplate -compatibilityLevel 14 -Identity "STS#1"
$w = Get-SPWebApplication http://portal.ad.madison.edu:82 

New-SPSite -Url $w.Url -Template $t -OwnerAlias AD\Admin -CompatibilityLevel 14 -Name "MIM Portal" -SecondaryOwnerAlias AD\BackupAdmin 
$s = SpSite($w.Url)
$s.AllowSelfServiceUpgrade = $false
$s.CompatibilityLevel