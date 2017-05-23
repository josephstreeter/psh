Function Get-DOITGroups {
$Groups = get-adgroup -F * -SearchBase "OU=SFS,OU=Project Groups,DC=ad,DC=doit,DC=wisc,DC=edu" -pr *
}

Function Rename-DOITGroups {
ForEach ($Group in $Groups) {
    if ($Group.GroupScope -eq "DomainLocal") {
        "SEWIN-DS-"+$Group.name.replace("\","-").replace(" ","-")
        }Else {
        "SEWIN-GS-"+$Group.name.replace("\","-").replace(" ","-")
        }
}
}

Function Get-DOITGroupMembers {
ForEach ($Group in $Groups) {
    if ($Group.GroupScope -eq "DomainLocal") {    
        "SEWIN-DS-"+$Group.Name.replace("\","-").replace(" ","-")
        ForEach ($Member in $Group.members) {
            Try {"     SEWIN-DS-"+$($Member | Get-ADGroup -ea Stop | select Name).name.replace("\","-").replace(" ","-")}
            Catch {"     "+$($Member | Get-ADUser | select Name).name}
            }
        ""
        }Else {
        "SEWIN-GS-"+$Group.Name.replace("\","-").replace(" ","-")
        ForEach ($Member in $Group.members) {
            Try {"     SEWIN-GS-"+$($Member | Get-ADGroup -ea Stop | select Name).name.replace("\","-").replace(" ","-")}
            Catch {"     "+$($Member | Get-ADUser | select Name).name}
            }
        }
}
}