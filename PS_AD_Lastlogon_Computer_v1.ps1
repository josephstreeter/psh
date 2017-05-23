$threeMonths = (Get-Date).addmonths(-3)
$sixMonths = (Get-Date).addmonths(-6)
$twelveMonths = (Get-Date).addmonths(-12)
$twentyfourMonths = (Get-Date).addmonths(-24)


"Computer Objects Not Used in Three to Six Months"
Get-ADComputer -filter {(LastLogonDate -lt $threeMonths) -and (LastLogonDate -gt $sixMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft name, LastLogonDate, enabled, distinguishedName -AutoSize

"Computer Objects Not Used in Six Months to One Year"
Get-ADComputer -filter {(LastLogonDate -lt $sixMonths) -and (LastLogonDate -gt $twelveMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft name, LastLogonDate, enabled, distinguishedName -AutoSize

"Computer Objects Not Used in One Year to Two Years"
Get-ADComputer -filter {(LastLogonDate -lt $twelveMonths) -and (LastLogonDate -gt $twentyfourMonths) -and (enabled -eq 'True')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft name, LastLogonDate, enabled, distinguishedName -AutoSize

"Disabled Computer Objects"
Get-ADComputer -filter {(enabled -eq 'False')} -SearchBase 'OU=orgUnits,DC=ad,DC=wisc,DC=edu' -Properties * | ft name, LastLogonDate, enabled, distinguishedName -AutoSize

	