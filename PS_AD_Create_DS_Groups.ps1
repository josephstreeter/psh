$domain = (Get-ADRootDSE).defaultnamingcontext
$path = "OU=Delegation,OU=groups,OU=wisc,$domain"

foreach ($attrib in $(get-content C:\scripts\groups.txt)) {
    "NETID-DS-Read-"+$attrib
    "NETID-DS-Write-"+$Attrib

New-ADGroup `
   -Name "NETID-DS-Read-$attrib" `
   -SamAccountName "NETID-DS-Read-$attrib" `
   -GroupCategory Security `
   -GroupScope Domainlocal `
   -DisplayName "NETID-DS-Read-$attrib" `
   -Path $path `
   -Description "Read NetID $attrib"

New-ADGroup `
   -Name "NETID-DS-Write-$attrib" `
   -SamAccountName "NETID-DS-Write-$attrib" `
   -GroupCategory Security `
   -GroupScope Domainlocal `
   -DisplayName "NETID-DS-Write-$attrib" `
   -Path $path `
   -Description "Write NetID $attrib"
    }