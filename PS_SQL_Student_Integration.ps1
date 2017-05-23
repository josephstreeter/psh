$CSInstance = "devdb1"
$CSDataBase = "CSTST"
$Query = @"
SELECT PK_EMPLID,LAST_NAME,FIRST_NAME,MIDDLE_INITIAL,FERPA
FROM PS_Z_ID_MGT_STU_VW
"@

$table = "ID_Test"
$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"

$Users = Invoke-Sqlcmd `
    -ServerInstance $CSInstance `
    -Database $CSDataBase `
    -query $Query `
    -Username "svc-csma-ts" `
    -Password "MadisonCollege2015_!"

$remaining = $users.Count

foreach ($User in $Users)
{
$remaining
$remaining--
$sqlCMD = @"
Declare @Employee_ID nvarchar(50) = '$($User.PK_EMPLID)'
Declare @First_Name nvarchar(50) = '$($User.First_Name)'
Declare @Last_Name nvarchar(50) = '$($User.Last_Name)'
Declare @Middle_Name nvarchar(50) = '$($User.MIDDLE_INITIAL)'
Declare @Employee_Type nvarchar(50) = 'S'

IF EXISTS (select employeeID from $table where employeeID = @Employee_ID AND EmployeeType = @Employee_Type)
	BEGIN
        UPDATE [dbo].[$table]
           SET [employeeID] = @Employee_ID
              ,[firstName] = @First_Name
              ,[lastName] = @Last_Name
              ,[initials] = @Middle_Name
              ,[employeeType] = @Employee_Type

         WHERE employeeID = @Employee_ID
	END
ELSE
	BEGIN
        INSERT INTO [dbo].[$table]
              ([employeeID]
              ,[firstName]
              ,[lastName]
              ,[initials]
              ,[employeeType])
        VALUES
              (@Employee_ID
              ,@First_Name
              ,@Last_Name
              ,@Middle_Name
              ,@Employee_Type)
	END
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $sqlCMD `
}