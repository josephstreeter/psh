
$O365cred=Get-Credential jstreeter@madisoncollege.edu
$O365session=New-PSSession –ConfigurationName Microsoft.exchange –ConnectionUri https://ps.outlook.com/powershell -AllowRedirection -Authentication Basic -Credential $O365cred
Import-PSSession $O365session
Connect-MsolService -Credential $O365cred
