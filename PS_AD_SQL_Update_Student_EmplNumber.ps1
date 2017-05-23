
Import-Module sqlps

$Instance = "csdb02.matc.madison.login"
$DataBase = "CSPRD"

$Students =@()
$Students += Get-ADUser -LDAPFilter '(!(employeeNumber=*))' -Properties employeeID,employeeType -searchbase "OU=Users,OU=Student,DC=MATC,DC=Madison,DC=Login"
$Students += Get-ADUser -LDAPFilter '(!(employeeNumber=*))' -Properties employeeID,employeeType -searchbase "OU=Student,OU=DisabledAccounts,DC=MATC,DC=Madison,DC=Login"
#$Students | select SamAccountName,EmployeeID,employeeType,Enabled,GivenName,Surname

$PropArray = @()

foreach ($Student in $Students)
    {
$Query = "SELECT * FROM PS_Z_ID_MGT_STU2VW WHERE PK_EMPLID = '$($Student.employeeID)'"
    $StdRecord = Invoke-Sqlcmd `
        -ServerInstance $Instance `
        -Database $DataBase `
        -query $Query `
        -Username "svc-csma-ts" `
        -Password "MadisonCollege2015_!" 
    
    $Prop = New-Object System.Object
    $Prop | Add-Member -type NoteProperty -name AccountName -value $Student.SamAccountName
    $Prop | Add-Member -type NoteProperty -name FirstName -value $Student.GivenName
    $Prop | Add-Member -type NoteProperty -name LastName -value $Student.Surname
    $Prop | Add-Member -type NoteProperty -name Initials -value $StdRecord.MIDDLE_INITIAL
    $Prop | Add-Member -type NoteProperty -name EmployeeID -value $Student.EmployeeID
    $Prop | Add-Member -type NoteProperty -name EmployeeType -value $Student.EmployeeType
    $Prop | Add-Member -type NoteProperty -name EmployeeNumber -value $StdRecord.GUID
    $Prop | Add-Member -type NoteProperty -name isFERPA -value $StdRecord.FERPA
    $Prop | Add-Member -type NoteProperty -name DateofBirth -value $StdRecord.BIRTHDATE

    $PropArray += $Prop
    }

$PropArray | ConvertTo-Csv | Out-File C:\Scripts\student_out.csv

$Users = gc C:\Scripts\student_out.csv | ConvertFrom-Csv


foreach ($User in $Users)
    {
    if ($User.EmployeeNumber)
        {
        if ((-not(Get-ADUser $($User.accountName) -pr employeenumber,employeetype).employeeNumber))
            {
            Set-ADUser $($User.accountName) -EmployeeNumber $($user.EmployeeNumber) -add @{employeeType="S"}
            }
        }
    }
