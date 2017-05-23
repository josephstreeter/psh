#Populate the department information below. 
#Multiple OU Admins can be specified, but they must each be in quotes and separated by a comma. ("admin1", "admin2", "admin3")

$OrgAdmins = "leinberger"
$OrgCode = "ENGL"
$orgUDDS = "A482400"
#$Global:orgName = "ENGLISH"
$RaDS = "No"
$SCS = "No"

$Modules = "activedirectory", "grouppolicy"
foreach ($module in $Modules){Import-Module $module}

$DomainName = (get-addomain).Forest.toupper()
$AD_Env = (get-addomain).Name

$OrgOU = "ou=" + $OrgCode + ",OU=orgUnits,DC=" + $AD_Env + ",DC=wisc,DC=edu"
$OrgSubOUss = "Computers", "Users", "Groups", "Servers"
$orgComputerOU = "ou=computers," + $OrgOU
$orgServerOU = "ou=servers," + $OrgOU
$OrgComputerGPO = $orgCode + "-Default-Computers"
$OrgServerGPO = $orgCode + "-Default-Servers"
$OrgOUOwners = $OrgCode + "-OU Owners"
$OrgOUAdmins = $OrgCode + "-OU Admins"

Function Get-Dept-Name {
$Global:orgName = ((Get-ADGroup ad-$orgUDDS-gs -pr description).description).replace(">","-")
}

Function New-Dept-Groups {
"Creating OU Owners/Administrator Groups and adding them to the appropraite groups"

New-ADGroup -Name $OrgOUOwners -SamAccountName $OrgOUOwners -GroupCategory Security -GroupScope Global -Path "OU=Groups,OU=Dept Admin,OU=ENT,DC=$AD_Env,DC=wisc,DC=edu" -Description $OrgName

New-ADGroup -Name $OrgOUAdmins -SamAccountName $OrgOUAdmins -GroupCategory Security -GroupScope Global -Path "OU=Groups,OU=Dept Admin,OU=ENT,DC=$AD_Env,DC=wisc,DC=edu" -Description $OrgName

Add-ADGroupMember "ad-all ou-owners-gs" -member $OrgOUOwners
Add-ADGroupMember "ad-All ou-admins-gs" -member $OrgOUAdmins
}


Function New-Dept-Users {
"Creating OU Owners and adding them to the appropriate groups"
foreach ($admin in $OrgAdmins)
    {

        $NetID = get-aduser -f {samaccountname -eq $admin} -pr *
        $AdminName = $NetID.samaccountname+"-ou"
        $AdminUPN = $NetID.samaccountname+"@"+$AD_Env+".wisc.edu"
        $length = 12
        $NonAlpha = 4

        Add-Type -Assembly System.Web
        $AdminPassword = [Web.Security.Membership]::GeneratePassword($length,$NonAlpha)
     if (get-aduser -f {cn -eq $AdminName}) {
        "$AdminName already Exists"
        }
     Else {
        New-ADUser $AdminName -path "OU=users,OU=Dept Admin,OU=ENT,DC=$AD_Env,DC=wisc,DC=edu" -AccountPassword  (ConvertTo-SecureString -AsPlainText $AdminPassword -Force) -Enabled $true -ChangePasswordAtLogon $true -givenname $NetID.givenname -surname $NetID.sn -displayname $NetID.displayname -UserPrincipalName $AdminUPN -description $orgName #-OtherAttributes @{mail=$NetID.mail;telephoneNumber=$NetID.telephoneNumber}
        Add-ADGroupMember $OrgOUOwners -member $AdminName

        "Username: " + $AdminName
        "Password: " + $AdminPassword
        ""
        }
    }
}

Function New-Dept-OU {
"Creating Top level OU and Default Sub OUs"

New-ADOrganizationalUnit -name $OrgCode -path "OU=orgUnits,DC=$AD_Env,DC=wisc,DC=edu" -Description $OrgName -ProtectedFromAccidentalDeletion $true

foreach ($SubOU in $OrgSubOUss)
    {
    New-ADOrganizationalUnit -name $SubOU -path $OrgOU -ProtectedFromAccidentalDeletion $true
    }
}

Function New-Dept-GPO {

"Creating Default Group Policy Objects "

Copy-GPO -sourcename "AD-TEMPLATE-Default-Computers" -Targetname $OrgComputerGPO
Copy-GPO -sourcename "AD-TEMPLATE-Default-Servers" -Targetname $OrgServerGPO
}

Function Link-Dept-GPO {
    "Linking the Default Group Policy Objects to the computers and servers OUs"
    Start-Sleep -s 2
    if (!(get-gpo -name $OrgComputerGPO -ea silentlycontinue)) {
        Link-Dept-GPO
        } 
    Else {
        New-GPLink -Name $OrgComputerGPO -Target $OrgComputerOU -LinkEnabled Yes
        New-GPLink -Name $OrgServerGPO -Target $OrgServerOU -LinkEnabled Yes

        "Adding OU Owners to the ACLs on the Default Group Policy Objects "
        Set-GPPermissions -name $OrgComputerGPO -TargetName $OrgOUOwners -TargetType Group -PermissionLevel GpoEditDeleteModifySecurity
        Set-GPPermissions -name $OrgServerGPO -TargetName $OrgOUOwners -TargetType Group -PermissionLevel GpoEditDeleteModifySecurity
        }
}

Function Add-Support {
if ($SCS -eq "Yes") {
    "Add SCS to group"
    Add-ADGroupMember $OrgOUOwners -member SCS-OU-Customer-Admin
    } Else {
    "Skip SCS"
    }

if ($RaDS -eq "Yes") {
    "Add RaDS to group"
    Add-ADGroupMember $OrgOUOwners -member RaDS-OU-Customer-Admin
    } Else {
    "Skip RaDS"
    }
}

##
##Get Department information
##
"Getting Dept Information"
Try { Get-Dept-Name }
Catch { "Department Information not found"; Exit }
##
##Create OU Owners/Administrator Groups and add them to the appropraite groups
##
New-Dept-Groups
##
##Create OU Owners and add them to the appropriate groups
##
If ($OrgAdmins) {New-Dept-Users} Else {"No users to create"}
##
## Create Top level OU and Default Sub OUs
##
New-Dept-OU
##
## Create and link a Group Policy Object to the "computers" OU
##
New-Dept-GPO
Link-Dept-GPO
##
## Add support groups to OU Owners
##
Add-Support
##
## Wrap-up
##