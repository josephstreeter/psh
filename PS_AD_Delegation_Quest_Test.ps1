$orgName = "AD-DEPT-TEST"
$orgOUs = 'ou=lab,dc=adtest,dc=wisc,dc=edu'
$orgGroups = 'ou=groups,ou=lab,dc=adtest,dc=wisc,dc=edu'
$orgOUadmins = 'CN=test-admins,ou=groups,ou=lab,dc=adtest,dc=wisc,dc=edu'
$orgOUowners = 'CN=test-owners,ou=groups,ou=lab,dc=adtest,dc=wisc,dc=edu'
$orgOU = 'ou=' + $orgName + ',' + $orgOUs
$orgComputersOU = 'ou=Computers,ou=' + $orgName + ',' + $orgOUs
$orgGroupsOU = 'ou=Groups,ou=' + $orgName + ',' + $orgOUs
$orgServersOU = 'ou=Servers,ou=' + $orgName + ',' + $orgOUs
$orgUsersOU = 'ou=users,ou=' + $orgName + ',' + $orgOUs
$orgAdminsGroup = 'ad\'+$orgName+'-OU-Admins-gs'
$orgOwnersGroup = 'ad\'+$orgName+'-OU-Owners-gs'
$orgGPO = $orgName+'-Default-'

#Import modules if needed
Import-Module activedirectory
Import-Module grouppolicy
Import-Module (get-pssnapin Quest.ActiveRoles.ADManagement -Registered).ModuleName

#Create Department Organizational Unit
new-qadObject -Name $orgName -ParentContainer $orgOUs -type 'organizationalUnit'
new-qadObject -Name Computers -ParentContainer $orgOU -type 'organizationalUnit'
new-qadObject -Name Groups -ParentContainer $orgOU -type 'organizationalUnit'
new-qadObject -Name Users -ParentContainer $orgOU -type 'organizationalUnit'
new-qadObject -Name Servers -ParentContainer $orgOU -type 'organizationalUnit'

#Create Department "Admins" and "Owners" groups
new-qadGroup -Name $orgName'-OU-Owners-gs' -SamAccountName $orgName'-OU-Owners-gs' -ParentContainer $orgGroups -GroupType Security -GroupScope Global
new-qadGroup -Name $orgName'-OU-Admins-gs' -SamAccountName $orgName'-OU-Admins-gs' -ParentContainer $orgGroups -GroupType Security -GroupScope Global

#Add Department groups to "all Owners" and "all Admins" groups
add-QADGroupMember -identity $orgOUadmins -member $orgName'-OU-Admins-gs'
add-QADGroupMember -identity $orgOUowners -member $orgName'-OU-Owners-gs'

#Delegate rights for Department Organizational Unit
#add-QADPermission $orgOU -Account $orgOwnersGroup -Rights 'GenericAll'
Add-QADPermission $orgComputersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'computer' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgComputersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'organizationalUnit' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgGroupsOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'group' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgGroupsOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'organizationalUnit' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgServersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'computer' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgServersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'organizationalUnit' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgUsersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'user' -ApplyTo 'all' -ApplyToType 'organizationalUnit'
Add-QADPermission $orgUsersOU -Account $orgOwnersGroup -Rights 'CreateChild' -ChildType 'organizationalUnit' -ApplyTo 'all' -ApplyToType 'organizationalUnit'

#Create GPOs
#New-GPO -Name $orgGPO'Desktops'
#New-GPO -Name $orgGPO'Laptops'
#New-GPO -Name $orgGPO'Servers'
#New-GPO -Name $orgGPO'Users'

#Copy Default GPOs
Copy-GPO -SourceName AD-DEFAULT-Default-desktops -TargetName $orgGPO'Desktops' 
Copy-GPO -SourceName AD-DEFAULT-Default-Laptops -TargetName $orgGPO'Laptops' 
Copy-GPO -SourceName AD-DEFAULT-Default-Servers -TargetName $orgGPO'Servers' 
Copy-GPO -SourceName AD-DEFAULT-Default-Users -TargetName $orgGPO'Users'

Start-Sleep -Seconds 4
New-GPLink -Name $orgGPO'desktops' -Target $orgComputersOU
New-GPLink -Name $orgGPO'laptops' -Target $orgComputersOU
New-GPLink -Name $orgGPO'servers' -Target $orgServersOU
New-GPLink -Name $orgGPO'users' -Target $orgUsersOU