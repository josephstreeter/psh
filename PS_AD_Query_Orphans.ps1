

Function Query-ADUsers($attrib,$User)
    {
    $Results=get-aduser -f {$attrib -eq $User} -pr LastLogonDate,employeeid,employeeType -ea 0 | select name,lastlogondate,distinguishedName,samaccountname,employeeID,employeeType
    Return $Results
    }

Function Import-PSData($CSV)
    {
    $Results = gc $csv | ConvertFrom-Csv
    Return $Results
    }

Function Determin-Container($DN)
    {
    If ($DN -like "*OrphansDis*") 
        {"DisabledOrphan"}
    ElseIf ($DN -like "*OrphansEna*") 
        {"EnabledOrphan"}
    ElseIf ($DN -like "*Student*") 
        {"Student"}
    ElseIf ($DN -like "*Admin*") 
        {"Admin"}
    ElseIf ($DN -like "*FacStaff*") 
        {"FacStaff"}
    ElseIf ($DN -like "*Disabled*") 
        {"Disabled"}
    ElseIf ($DN -like "*EmailOnly*") 
        {"Retired"}
    Else {"No Idea"}
    }

$CSV="C:\Scripts\PS_employee.csv"
$rpt=@()
$PSEmployees=Import-PSData $CSV

foreach ($PSEmployee in $PSEmployees)
    {
    if ($PSEmployee.Network_id)
        {
        if ($Match) {Clear-Variable Match}
        $Match=Query-ADUsers "sAMAccountName" $PSEmployee.Network_id
        $rpt+=New-Object psobject -Property @{
                                        "FirstName"=$PSEmployee.FIRST_NAME
                                        "LastName"=$PSEmployee.LAST_NAME
                                        "MiddleName"=$PSEmployee.MIDDLE_NAME
                                        "Email"=$PSEmployee.EMAIL_ADDR
                                        "UserName"=$PSEmployee.NETWORK_ID
                                        "LPD"=$PSEmployee.LAST_PAY_DATE_ANY_JOB
                                        "PSEmplID"=$PSEmployee.EmplID
                                        "ADEmplID"=$(If ($Match){$match.EmployeeID}Else{$null})
                                        "ADObject"=$(If ($Match){$True}Else{$False})
                                        "ADLocation"=$(If ($Match){Determin-Container $($Match.distinguishedName)}Else{$null})
                                        "LastLogon"=$(If ($Match){$match.LastLogonDate}Else{$null})
                                        }
        }
    }
$rpt | ft FirstName,LastName,MiddleName,Email,UserName,PSEmplID,ADEmplID,LPD,ADObject,ADLocation,LastLogon -auto

$rpt | ? {($_.ADObject -eq $True)-and($_.ADLocation -ne "Orphan")} | ft FirstName,LastName,MiddleName,Email,UserName,PSEmplID,ADEmplID,LPD,ADObject,ADLocation,LastLogon -auto

"Total number of records in PS Data"
$PSEmployees.count
"`nTotal number of records in PS Data with UserID"
$Rpt.count
"`nTotal number of records in PS Data without UserID (could still be matched using EmployeeID or email alias)"
$($PSEmployees.count) - $($Rpt.count)
"`nPS Record matches Active or Disabled AD Object (May have been reused by HR or Student ERP)"
($rpt | ? {($_.ADObject -eq $True)-and($_.ADLocation -ne "Orphan")}).count
"`nPS Record matches Disabled Orphaned AD Object (May include duplicates)"
($rpt | ? {($_.ADObject -eq $True)-and($_.ADLocation -eq "DisabledOrphan")}).count
"`nPS Record matches Enabled Orphaned AD Object (May include duplicates)"
($rpt | ? {($_.ADObject -eq $True)-and($_.ADLocation -eq "EnabledOrphan")}).count
"`nPS Record does not match any AD Object (May cause a duplicate due to being entered into WD without checking old PS data)"
($rpt | ? {($_.ADObject -eq $False)}).count