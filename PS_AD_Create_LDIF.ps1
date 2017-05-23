$users = Get-ADUser -f *
$path = "c:\temp\LDIF$(get-date -Format yyyyMMdd).txt"          

If (Get-Item $Path)
    { 
    Remove-Item $path
    }

New-Item -Path $path -ItemType File -Force          
Add-Content -Value "version: 1" -Path $path          
        
Foreach ($User in $Users)
    {          
    $value = @"

    dn: cn=$($User.samaccountname),ou=users,ou=managed,dc=ad,dc=madison,dc=edu
    changetype: add
    userPassword: P@ssw0rd
    uid: $($user.samaccountname)
    userprincipalname: $($User.UserPrincipalName) 
    givenName: $($user.givenname)
    fullName: $($User.name)
    sn: $($User.surname)
    objectClass: inetOrgPerson
    objectClass: organizationalPerson
    objectClass: Person
    objectClass: Top
    cn: $($User.name)
"@          
    Add-Content -Value $value -Path $path          
    }

    GC $Path 