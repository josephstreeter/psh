#$users = get-aduser -Filter {admincount -eq 1} -pr memberof -SearchBase "ou=facstaff,dc=matc,dc=madison,dc=login"
#$users | % {"`n" + $_.name ;$_.memberof | % {"  " + $(get-adgroup $_ -ea 0).name}}


$Groups = "Account Operators", 
"Administrators",
"Backup Operators",
"Domain Admins",
"Print Operators",
"Server Operators"

#"Enterprise Admins",
#"Schema Admins"

Foreach ($Group in $Groups)
    {
    "`n $Group" 
    "______________________"
    $Members = Get-adgroupmember $Group -Recursive
    If ($members.count -gt 0) 
        {
        $Members | ft name
        }
        Else
        {
        "No Members"
        }
    }