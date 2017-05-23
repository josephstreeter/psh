
$users=Get-AdUser -Filter * | Where {(-Not $_.UserPrincipalName.ToLower().StartsWith(“svc-”)) -and (-Not $_.UserPrincipalName.ToLower().EndsWith(“@ad-test.wisc.edu”))}
$i=$users.count

ForEach ($user in $users)
   {
   Set-AdUser $User.name -UserPrincipalName $User.UserPrincipalName.Split("@")[0]+"@ad-test.wisc.edu”
   if ($?) {$i--}
   $_.UserPrincipalName + " " + $i
   }