$table = "ID_Test"
$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"

$Users = import-csv C:\Scripts\student_out1.csv

foreach ($User in $Users)
{
if ($User.disabled -eq "True"){$EmplStatus = "D"}Else{$EmplStatus = "A"}

$($User.FirstName) + "  " + $($User.LastName)
$sqlCMD = @"
Declare @Employee_ID nvarchar(50) = '$($User.EmplID)'
Declare @First_Name nvarchar(50) = '$($User.FirstName)'
Declare @Middle_Name nvarchar(50) = '$($User.initials)'
Declare @Last_Name nvarchar(50) = '$($User.LastName)'
Declare @Employee_Type nvarchar(50) = 'S'
Declare @Employee_Status nvarchar(50) = '$($emplStatus)'
Declare @Name nvarchar(50) = '$($User.cn)'

IF EXISTS (select employeeID from $table where (employeeID = @Employee_ID) and (AccountName = @Name) )
	BEGIN
        UPDATE [dbo].[$table]
           SET [employeeID] = @Employee_ID
              ,[firstName] = @First_Name
              ,[lastName] = @Last_Name
         WHERE employeeID = @Employee_ID
	END
ELSE
	BEGIN
        INSERT INTO [dbo].[$table]
              ([employeeID]
              ,[firstName]
              ,[lastName]
              ,[initials]
              ,[EmployeeType]
              ,[EmployeeStatus]
              ,[accountName])
        VALUES
              (@Employee_ID
              ,@First_Name
              ,@Last_Name
              ,@Middle_Name
              ,@Employee_Type
              ,@Employee_Status
              ,@Name)
	END
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $sqlCMD
}