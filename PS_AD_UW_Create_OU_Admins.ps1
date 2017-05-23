
Function Create-Admin($admin){
    $AdminName = $NetID.samaccountname+"-ou"
    $AdminUPN = $NetID.samaccountname+"@ad.wisc.edu"
    $length = 12
    $NonAlpha = 4

    Add-Type -Assembly System.Web
    $AdminPassword = [Web.Security.Membership]::GeneratePassword($length,$NonAlpha)

    New-ADUser $AdminName -path 'OU=OU-Admins,OU=adminAccounts,OU=manageDomain,DC=ad,DC=wisc,DC=edu' `
	  -AccountPassword  (ConvertTo-SecureString -AsPlainText $AdminPassword -Force) -Enabled $true `
	  -ChangePasswordAtLogon $False -givenname $NetID.givenname -surname $NetID.sn -displayname $NetID.displayname `
	  -UserPrincipalName $AdminUPN -OtherAttributes @{mail=$NetID.mail;telephoneNumber=$NetID.telephoneNumber}

    "Username: " + $AdminName
    "Password: " + $AdminPassword
    ""
	}
$NetID = $null
$OrgAdmins = "sjkohlbe","jfortune","estraava","ctcudd","jrthompson2","mablasinski","dgkarnowski","mgweber","jeremy","larcheidt"

foreach ($admin in $OrgAdmins)
    {
    $NetID = get-aduser -f {samaccountname -eq $admin} -pr *
	if ($NetID) {Create-Admin}
	else {Write-Host -ForegroundColor Red "NetID $admin does not exist"}
	}