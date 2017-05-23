Function Rename-Admins {
$Groups = Get-ADGroup -f {name -like "*Admins-gs-test"} -SearchBase "ou=groups,ou=ent,dc=ad,dc=wisc,dc=edu"

foreach ($Group in $Groups) {
    $GroupName = "CADS-GS-"+ $Group.name.replace("-OU Admins-gs","")+"-OU-ADMINS-test"
    Get-ADGroup $Group.Name | Rename-ADObject -NewName $GroupName -PassThru 
    }
}

Function Rename-Owners {
$Groups = Get-ADGroup -f {name -like "*Owners-gs-test"} -SearchBase "ou=groups,ou=ent,dc=ad,dc=wisc,dc=edu"

foreach ($Group in $Groups) {
    $GroupName = "CADS-GS-"+ $Group.name.replace("-OU Owners-gs","")+"-OU-OWNERS-test"
    Get-ADGroup $Group.Name | Rename-ADObject -NewName $GroupName -PassThru 
    }
}

Rename-Owners
Rename-Admins