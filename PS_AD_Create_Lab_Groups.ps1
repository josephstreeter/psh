Function Create-Groups {
$Groups = Get-ADGroup -f * -SearchBase "ou=groups,ou=dept admin,ou=ent,dc=ad,dc=wisc,dc=edu"

foreach ($Group in $Groups) {
    $GroupName = $Group.name + "-test"
    New-ADGroup `
        -Name $GroupName `
        -GroupScope "global" `
        -path "ou=groups,ou=ent,ou=lab,dc=ad,dc=wisc,dc=edu" `
        -passthru
    }
}

Create-Groups