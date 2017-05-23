$OrgAdmins = "gnice"
$OrgCode = "AGRO-SOY"
$OrgName = "COLLEGE OF AGRICULTURAL & LIFE SCIENCES - AGRONOMY - SOY"

$OrgOU = "ou=" + $OrgCode + ",OU=orgUnits,DC=adtest,DC=wisc,DC=edu"
$OrgSubOUss = "Computers", "Users", "Groups", "Servers"
$orgComputerOU = "ou=computers," + $OrgOU
$orgServerOU = "ou=servers," + $OrgOU
$OrgComputerGPO = $orgCode + "-Default-Computers"
$OrgServerGPO = $orgCode + "-Default-Servers"
$OrgOUOwners = $OrgCode + "-OU Owners"
$OrgOUAdmins = $OrgCode + "-OU Admins"
$Modules = "activedirectory", "grouppolicy"

foreach ($module in $Modules){Import-Module $module}

##
##Create OU Owners/Administrator Groups and add them to the appropraite groups
##

"Creating OU Owners/Administrator Groups and adding them to the appropraite groups"

New-ADGroup -Name $OrgOUOwners -SamAccountName $OrgOUOwners -GroupCategory Security -GroupScope Global -Path 'OU=orgUnits,OU=Groups,OU=manageDomain,DC=adtest,DC=wisc,DC=edu' -Description $OrgName

New-ADGroup -Name $OrgOUAdmins -SamAccountName $OrgOUAdmins -GroupCategory Security -GroupScope Global -Path 'OU=orgUnits,OU=Groups,OU=manageDomain,DC=adtest,DC=wisc,DC=edu' -Description $OrgName

Add-ADGroupMember "ad-all ou-owners-gs" -member $OrgOUOwners
Add-ADGroupMember "ad-All ou-admins-gs" -member $OrgOUAdmins

##
##Create OU Owners and add them to the appropriate groups
##

"Creating OU Owners and adding them to the appropriate groups"
foreach ($admin in $OrgAdmins)
    {
    $NetID = get-aduser -f {samaccountname -eq $admin} -pr *
    $AdminName = $NetID.samaccountname+"-ou"
    $AdminUPN = $NetID.samaccountname+"@adtest.wisc.edu"
    $length = 12
    $NonAlpha = 4

    Add-Type -Assembly System.Web
    $AdminPassword = [Web.Security.Membership]::GeneratePassword($length,$NonAlpha)

    New-ADUser $AdminName -path 'OU=OU-Admins,OU=adminAccounts,OU=manageDomain,DC=adtest,DC=wisc,DC=edu' -AccountPassword  (ConvertTo-SecureString -AsPlainText $AdminPassword -Force) -Enabled $true -ChangePasswordAtLogon $true -givenname $NetID.givenname -surname $NetID.sn -displayname $NetID.displayname -UserPrincipalName $AdminUPN -description $orgName -OtherAttributes @{mail=$NetID.mail;telephoneNumber=$NetID.telephoneNumber}
    Add-ADGroupMember $OrgOUOwners -member $AdminName

    "Username: " + $AdminName
    "Password: " + $AdminPassword
    ""
    }


##
## Create Top level OU and Default Sub OUs
##
"Creating Top level OU and Default Sub OUs"

New-ADOrganizationalUnit -name $OrgCode -path "OU=orgUnits,DC=adtest,DC=wisc,DC=edu" -Description $OrgName -ProtectedFromAccidentalDeletion $true

foreach ($SubOU in $OrgSubOUss)
    {
    New-ADOrganizationalUnit -name $SubOU -path $OrgOU -ProtectedFromAccidentalDeletion $true
    }

##
## Create and link a Group Policy Object to the "computers" OU
##
"Creating and linking the Default Group Policy Object to the computers OU"

Copy-GPO -sourcename "AD-TEMPLATE-Default-Computers" -Targetname $OrgComputerGPO
Copy-GPO -sourcename "AD-TEMPLATE-Default-Servers" -Targetname $OrgServerGPO
Start-Sleep -s 9
New-GPLink -Name $OrgComputerGPO -Target $OrgComputerOU -LinkEnabled Yes
New-GPLink -Name $OrgServerGPO -Target $OrgServerOU -LinkEnabled Yes

