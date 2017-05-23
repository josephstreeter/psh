Param(
  [parameter(Mandatory=$true)]
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

foreach ($User in $Users)
    {
    $ADUser = Query_AD $User
    $SDUser = Query_SD $User
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
        "Activated" = $(if ($ADUser.carlicense -eq "pwmNewAccount"){"Not Activated"}Elseif((-Not($ADUser.carlicense)) -or ($ADUser.carlicense -eq "pwmActivated")){"Activated"})
        }
    }

$Results | select UserID_AD,UserID_SD | ft -AutoSize
$Results | select EmplID_AD,EmplID_SD | ft -AutoSize
$Results | select EmplType_AD,EmplType_SD | ft -AutoSize
$Results | select EmplStatus_SD | ft -AutoSize
$Results | select EmplNum_AD,EmplNum_SD | ft -AutoSize
$Results | select Activated | ft -AutoSize