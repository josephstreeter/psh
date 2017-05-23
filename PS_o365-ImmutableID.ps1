#$user = “<user>@uwtest.OnMicrosoft.com”
#$cred = Get-Credential -Credential $user

#Import-Module MSOnline

#Connect-MsolService -Credential $cred



$cn = "jstreeter"
$guid = (get-aduser -f {cn -eq $cn} -pr objectguid).objectguid
$upn  = (get-aduser -f {cn -eq $cn}).userprincipalname
$ImmutableID = [System.Convert]::ToBase64String($guid.ToByteArray())

set-msolUser -userprincipalname $upn -immutableID $ImmutableID
