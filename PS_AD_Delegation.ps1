$orgName = "DoIT-SE"

New-ADGroup -Name $orgName"-OU-Owners-gs" -Path "ou=orgUnits,ou=groups,ou=manageDomain,dc=ad,dc=wisc,dc=edu" -GroupScope Global
New-ADGroup -Name $orgName"-OU-Admins-gs" -Path "ou=orgUnits,ou=groups,ou=manageDomain,dc=ad,dc=wisc,dc=edu" -GroupScope Global
New-ADOrganizationalUnit -Name $orgName -Path "ou=orgUnits,dc=ad,dc=wisc,dc=edu" -ProtectedFromAccidentalDeletion $true

