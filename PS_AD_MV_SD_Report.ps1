Param(
  [string[]]$Users
)

$Results = @()

Function Query_AD($User)
    {
    $Result = Get-ADUser -f {sAMAccountName -eq $User} -pr employeeNumber,employeeID,employeeType,carlicense
    Return $Result
    }

Function Update_AD($User)
    {
    $EmplNum = $User.EmplNum_SD
    $UserID = $User.UserID_AD
    Get-ADUser -f {sAMAccountName -eq $UserID} | Set-ADUser -EmployeeNumber $EmplNum -PassThru
    }

Function Query_SD($User)
    {
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
        WHERE accountName = '$User'
"@
    $Result=Invoke-Sqlcmd `
        -ServerInstance $Instance `
        -Database $DataBase `
        -query $Query
    Return $Result
    }

Function Query_MV($User)
    {
    $Instance = "IDMDBPRD01\MIMSYnc"
    $DataBase = "FIMSynchronization"
    $Query = @"
        SELECT accountName
                ,firstname
                ,lastName
                ,initials
                ,employeeID
                ,employeeNumber
                ,employeeType
                ,employeeStatus
        FROM mms_metaverse
        WHERE accountName = '$User'
"@
    $Result=Invoke-Sqlcmd `
        -ServerInstance $Instance `
        -Database $DataBase `
        -query $Query
    Return $Result
    }

foreach ($User in $Users)
    {
    $ADUser = Query_AD $User
    $SDUser = Query_SD $User
    $MVUser = Query_MV $User
    $Results += New-Object PSObject -Property @{
        "UserID_AD" = $ADUser.sAMAccountName
        "UserID_SD" = $SDUser.AccountName
        "UserID_MV" = $MVUser.AccountName
        "EmplID_AD" = $ADUser.employeeID
        "EmplID_SD" = $SDUser.employeeID
        "EmplID_MV" = $MVUser.employeeID
        "EmplType_AD" = $ADUser.employeeType
        "EmplType_SD" = $SDUser.employeeType
        "EmplType_MV" = $MVUser.employeeType
        "EmplStatus_SD" = $SDUser.employeeStatus
        "EmplStatus_MV" = $MVUser.employeeStatus
        "EmplNum_AD" = $ADUser.employeeNumber
        "EmplNum_SD" = $SDUser.employeeNumber
        "EmplNum_MV" = $MVUser.employeeNumber
        "Activated" = $ADUser.carlicense
        }
    }

$Results | select UserID_AD,UserID_SD,UserID_MV | ft -AutoSize
$Results | select EmplID_AD,EmplID_SD,EmplID_MV | ft -AutoSize
$Results | select EmplType_AD,EmplType_SD,EmplType_MV | ft -AutoSize
$Results | select EmplStatus_SD,EmplStatus_MV | ft -AutoSize
$Results | select EmplNum_AD,EmplNum_SD,EmplNum_MV | ft -AutoSize