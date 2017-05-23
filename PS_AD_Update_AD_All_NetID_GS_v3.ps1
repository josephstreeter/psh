"Load Modules`n"
import-module activedirectory

"Set Date"
$date = get-date -uformat "%Y-%m-%d"
"$Date`n"

"`nSet Domain"
$Domain = (get-addomain).Forest.toupper()
"$Domain`n"

#######################################################################
#						Update Groups                                 #
#######################################################################
"Add users to ad-all netid-gs"
$a=$b=$c=$d=0
Get-ADUser -Filter {(altSecurityIdentities -like "*LOGIN.WISC.EDU") -and (-not (memberof -eq "CN=ad-all netid-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu"))} `
-pr altsecurityidentities, memberof -ResultPageSize 1000 -searchbase "ou=NetID,ou=Wisc,DC=ad,dc=wisc,dc=edu" | % {add-ADGroupMember "ad-All NetID-gs" -Members $_ ; $_.name + "  " + $a ;$a++}
"$a`n"

"Add users to ad-all guestnetids-gs"
Get-ADUser -Filter {(altSecurityIdentities -like "*LOGIN.WISC.EDU") -and (-not (memberof -eq "CN=ad-all guestnetids-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu"))} `
-pr altsecurityidentities, memberof -ResultPageSize 1000 -searchbase "ou=guestNetID,ou=Wisc,DC=ad,dc=wisc,dc=edu" | % {add-ADGroupMember "ad-All guestNetIDs-gs" -Members $_ ; $_.name + "  " + $b ;$b++}
"$b`n"

"Remove users from ad-all netid-gs"
Get-ADUser -Filter {(-not (altSecurityIdentities -like "*LOGIN.WISC.EDU")) -and (memberof -eq "CN=ad-all netid-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu")} `
-pr altsecurityidentities, memberof -ResultPageSize 1000 -searchbase "ou=NetID,ou=Wisc,DC=ad,dc=wisc,dc=edu" | % {remove-ADGroupMember "ad-All NetID-gs" -Members $_ -confirm:$false; $_.name + "  " + $c ;$c++}
"$c`n"

"Remove users from ad-all guestnetids-gs"
Get-ADUser -Filter {(-not (altSecurityIdentities -like "*LOGIN.WISC.EDU")) -and (memberof -eq "CN=ad-all guestnetids-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu")} `
-pr altsecurityidentities, memberof -ResultPageSize 1000 -searchbase "ou=guestNetID,ou=Wisc,DC=ad,dc=wisc,dc=edu" | % {remove-ADGroupMember "ad-GuestAll NetIDs-gs" -Members $_ -confirm:$false; $_.name + "  " + $d ;$d++}
"$d`n"

#######################################################################
#						Send Message                                  #
#######################################################################
$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "joseph.streeter@doit.wisc.edu"
$mailto = "joseph.streeter@doit.wisc.edu"

$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = $mailFrom
$msg.To.Add($mailTo)
$msg.Subject = "All NetID/GuestNetID Users Update - $date ($domain)"
$msg.Body = "$a NetID users and $b Guest NetID users were added `n$c NetID users and $d Guest NetIDs were removed"

#$smtp.Send($msg)
