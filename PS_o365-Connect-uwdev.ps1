$user = “joe@uwdev.OnMicrosoft.com”
$cred = Get-Credential -Credential $user

Import-Module MSOnline


Connect-MsolService -Credential $cred


#$msoExchangeURL = “https://ps.outlook.com/powershell/”
#$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection

#Import-PSSession $session