$OUs = @(
    "Staff;OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Faculty;OU=Faculty,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Tech Services;OU=TechServices,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Administration;OU=Admin,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Contingent;OU=NonEmployee,DC=MATC,DC=Madison,DC=login"#,
    #"OU=EmailOnly,DC=MATC,DC=Madison,DC=login"
    )

$Instance = "IDMDBPRD01\MIMStage"
$DataBase = "StagingDirectory"
$Query = @"
SELECT accountName
        ,firstname
        ,lastName
        ,initials
        ,employeeID
        ,employeeNumber
        ,employeeType
        ,employeeStatus
FROM identities
WHERE employeeID = '$employeeID' 
"@

$DisabledOUs = @(
    "OU=Staff,OU=DisabledAccounts,DC=MATC,DC=Madison,DC=login",
    "OU=Faculty,OU=DisabledAccounts,DC=MATC,DC=Madison,DC=login"
    )

$users = @()
$Report =@()

Function Query-Stage($employeeID)
    {
    $Query = @"
        SELECT accountName
                ,firstname
                ,lastName
                ,initials
                ,employeeID
                ,employeeNumber
                ,employeeType
                ,employeeStatus
        FROM identities
        WHERE employeeID = '$employeeID'
"@
    $a=Invoke-Sqlcmd `
        -ServerInstance $Instance `
        -Database $DataBase `
        -query $Query
    Return $a
    }

Function Query-AD
    {
    Foreach ($OU in $OUs)
        {
        $users += Get-ADUser -f * -pr lastLogonDate,employeeID,employeeNumber,employeeType -SearchBase $ou.Split(";")[1]
        }
    return $Users
    }

$Users = Query-AD $OUs

Foreach ($User in $users)
    {
    if ($User.name -ne $User.samaccountName)
        {
        $Results = Query-Stage $User.EmployeeID
        $Report += New-Object PSObject -Property @{
            "Name" = $User.name
            "UserID-AD" = $User.samaccountName
            "UserID-SD" = $(if ($Results.AccountName){$Results.accountName}Else{"NA"})
            "EmplID-AD" = $User.employeeID
            "EmplID-SD" = $(if ($Results.employeeID){$Results.employeeID}Else{"NA"})
            "EmplNum-AD" = $User.employeeNumber
            "EmplNum-SD" = $(if ($Results.employeeNumber){$Results.employeenumber}Else{"NA"})
            "EmplType-AD" = $User.employeeType
            "EmplType-SD" = $(if ($Results.employeeType){$Results.employeeType}Else{"NA"})
            "EmplStatus-SD" = $(if ($Results.employeeStatus){$Results.employeeStatus}Else{"NA"})
            "LastLogon" = $User.lastLogonDate
            "DN" = $User.distinguishedName
            
            }

        }
    }

$Report | select name,UserID-AD,UserID-SD,emplID-AD,emplID-SD,emplNum-AD,emplNum-SD,emplType-AD,emplType-SD,emplStatus-SD,lastLogon,dn | ConvertTo-Csv | Out-File C:\Scripts\orphaned_User_object_report.csv