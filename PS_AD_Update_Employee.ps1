#$Users=@()
$users = Import-Csv .\employee_out.csv 

Function Set-ADUserObject($cn,$emplid)
    {
    get-aduser -filter {samaccountname -eq $cn} -ea 0 | Set-ADUser -EmployeeID $emplid -PassThru
    }

Function Get-ADUserObject($cn,$emplid)
    {
    if (get-aduser -filter {samaccountname -eq $cn} -ea 0){Set-ADUserObject $cn $emplid} Else {"no"}
    }

$users | % {[string]$cn=$_.cn;[string]$emplid=$_.emplid;Get-ADUserObject $cn $emplid}