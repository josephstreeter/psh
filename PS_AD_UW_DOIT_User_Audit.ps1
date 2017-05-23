if (-not (get-psdrive DOIT -ea silentlycontinue)) {
    $Admin = Read-Host "Enter Prod AD Admin Username"
    New-PSDrive `
        –Name DOIT `
        –PSProvider ActiveDirectory `
        –Server "ad.doit.wisc.edu" `
        –Credential (Get-Credential "$Admin") `
        –Root "//RootDSE/" `
        -Scope Global
        }

cd DOIT:

$users = get-aduser -f * -pr * -SearchBase "OU=UW-System Users,DC=ad,DC=doit,DC=wisc,DC=edu"

Function Create-Reports {
"Disabled Users"
$users | ? {$_.enabled -eq $false} |  select name,userprincipalname,altsecurityidentities,lastlogondate,enabled,whencreated,notes | ft -AutoSize

"No kerberos principal and no last logon date"
$users | ? {($_.LastLogonDate -eq $NULL) -and (-not($_.altsecurityidentities -like "*"))} |  select name,userprincipalname,altsecurityidentities,lastlogondate,enabled,whencreated | ft -AutoSize

"No Group memberships"
$Users | ? {-not($_.Memberof -like "*")} | select name,userprincipalname,altsecurityidentities,lastlogondate,enabled,whencreated,memberof | ft -AutoSize

'"_sfs" users'
$Users | ?  {$_.saMAccountName -like "*_sfs"} | select name,userprincipalname,altsecurityidentities,lastlogondate,enabled,whencreated | ft -AutoSize

'Users that have not logged in in over a year'
$Users | ?  {($_.lastlogondate -lt $(get-date).AddDays(-365)) -and (-not($_.altsecurityidentities -like "*"))} | select name,userprincipalname,altsecurityidentities,lastlogondate,enabled,whencreated | ft -AutoSize

}

Create-Reports | out-file C:\Scripts\doit_user_audit.txt