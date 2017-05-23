import-module activedirectory
Function Get-Menu {
"#############################################"
"Campus Active Directory Admin Management     "
"                                             "
"#############################################"
""
"Admin Tasks"
"1 Create New OU Owner"
"2 Reset Password"
"3 Add OU Owner to Group"
"q Exit"
$Task = Read-Host "Enter Choice"

Switch ($Task) {
	"1" {Create-Admin}
	"2" {Reset-Password}
	"3" {Join-Group}
	"q" {Break}
	Default {Get-Menu}
	}
}

Function Get-NetID {
Clear-Host 
$NetID = Read-Host "Enter NetID"
$Global:User = Get-ADUser $NetID -pr *

"NetID: " + $User.name
"Display Name: " + $User.DisplayName
"First Name: " + $User.GivenName
"Last Name: " + $User.sn
"Initial: " + $User.Initials
"Email: " + $User.EmailAddress
"Office: " + $user.physicalDeliveryOfficeName
"UPN: " + $User.UserPrincipalName
""
$Create = Read-Host "Is this the correct User? y/n"

Switch ($Create) {
	"y" {Return}
	"n" {Get-NetID}
	default {"Uh oh, its broken"; Break}
}
}

Function Create-Admin {
Get-NetID
"Create admin account for " + $User.CN
Get-Menu
}

Function Reset-Password {
Get-NetID
Clear-Host
"Reset admin Password for " + $User.CN
$Passwd1 = Read-Host "Enter Password" -AsSecureString
$Passwd2 = Read-Host "Confirm Password" -AsSecureString 
If ($Passwd1 -match $Passwd2) {"Password reset"; Get-Menu}
Else {"Passwords do not match"; Reset-Password}
}

Function Join-Group {
Get-NetID
Clear-Host
$Groups = get-adgroup -f {cn -like "*Owners-gs"} -searchbase "ou=orgunits,ou=groups,ou=managedomain,dc=ad,dc=wisc,dc=edu"
"Chose Group"
$i=0; do {"$i " + $Groups[$i].name; $i++} while ($i -lt $Groups.length)
$GroupNumber = Read-Host "Chose"
Clear-Host
"Add " + $user.name + " to " + $Groups[$GroupNumber].name
Get-Menu
}
Clear-Host
Get-Menu
