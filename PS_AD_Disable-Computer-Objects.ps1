$computers = Get-ADComputer -filter * -searchbase 'ou=computers,ou=orgUnits,dc=ad,dc=wisc,dc=edu'

foreach ($computer in $computers){Set-ADComputer $computer.name -enable $true -location "Disabled 06/13/2012"}