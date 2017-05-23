$date = (get-date).ToShortDateString().Replace("/","-")
$file = "Stale-Administrator-Report.txt"
$rpt = ".\" + $date + "-" + $file
$date = (Get-Date).addmonths(-12)
$dn = "ou=users,ou=Dept Admin,ou=ENT,dc=ad,dc=wisc,dc=edu"

"Stale OU Administrator Report" | Out-File $rpt

"Administrator Accounts Not Used in One Year" | Out-File -Append $rpt
Get-ADUser -filter {(LastLogonDate -lt $date)-and (enabled -eq 'True')} -SearchBase $dn -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize | Out-File -Append $rpt

"Disabled Administrator Accounts" | Out-File -Append $rpt
Get-ADUser -filter {(enabled -eq 'False')} -SearchBase $dn -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize | Out-File -Append $rpt

"Administrator Accounts That Have Not Been Used" | Out-File -Append $rpt
Get-ADUser -filter {-not(LastLogonDate -ne "*")} -SearchBase $dn -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize | Out-File -Append $rpt