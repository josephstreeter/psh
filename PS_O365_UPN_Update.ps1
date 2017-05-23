
$users=Get-MsolUser -all | Where {(-Not $_.UserPrincipalName.ToLower().StartsWith(“svc-”)) -and (-Not $_.UserPrincipalName.ToLower().EndsWith(“@ad-test.wisc.edu”))}
$i=$users.count

ForEach ($user in $users)
   {
   Set-MsolUserPrincipalName -ObjectId $User.ObjectId -NewUserPrincipalName($User.UserPrincipalName.Split("@")[0]+"@ad-test.wisc.edu”) 
   if ($?) {$i--}
   $User.UserPrincipalName + " " + $i
   }