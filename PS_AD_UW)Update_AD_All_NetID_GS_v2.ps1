Import-Module ActiveDirectory
If (-not $?) { "Failed to import AD module!" ; exit }

$i = 0

$users = Get-ADUser -Filter {(altSecurityIdentities -like "*") -and (memberof -ne "CN=ad-all netid-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu")} -Pr altSecurityIdentities, memberof -searchbase "ou=NetID,ou=Wisc,DC=ad,dc=wisc,dc=edu"

if ($users -ge 1){foreach ($user in $users) {$user.name; Add-ADGroupMember "ad-all NetID-gs" $user.samaccountname; $i++};"$i users added to group"}Else{"No user objects to add"}

#Reverse of the filter used above
#Get-ADUser -Filter {(-not(altSecurityIdentities -like "*")) -and (memberof -eq "CN=ad-all netid-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu")} -Pr altSecurityIdentities, memberof -searchbase "ou=NetID,ou=Wisc,DC=ad,dc=wisc,dc=edu" | ft name, memberof, altsecurityidentities