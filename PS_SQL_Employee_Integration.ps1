$table = "ID_Test"
$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"

$Users = import-csv D:\INT201_WDtoIDM_20160203134826.csv

foreach ($User in $Users)
{
$sqlCMD = @"
Declare @Employee_ID nvarchar(50) = $($User.Employee_ID)
Declare @Name nvarchar(50) = '$($User.Name)'
Declare @First_Name nvarchar(50) = '$($User.First_Name)'
Declare @Middle_Name nvarchar(50) = '$($User.Middle_Name)'
Declare @Last_Name nvarchar(50) = '$($User.Last_Name)'
Declare @Work_Address_Line1_Data nvarchar(50) = '$($User.Work_Address_Line1_Data)'
Declare @Work_Address_Line2_Data nvarchar(50) = '$($User.Work_Address_2ine1_Data)'
Declare @Work_Municipality nvarchar(50) = '$($User.Work_Municipality)'
Declare @Work_Region nvarchar(50) = '$($User.Work_Region)'
Declare @Work_Postal_Code nvarchar(50) = '$($User.Work_Postal_Code)'
Declare @Home_Email_Address nvarchar(50) = '$($User.Home_Email_Address)'
Declare @Office_Phone nvarchar(50) = '$($User.Office_Phone)'
Declare @Mobile_Phone nvarchar(50) = '$($User.Mobile_Phone)'
Declare @Room_Number nvarchar(50) = '$($User.Room_Number)'
Declare @Company nvarchar(50) = '$($User.Company)'
Declare @Hire_Date nvarchar(50) = '$($User.Hire_Date)'
Declare @Termination_Date nvarchar(50) = '$($User.Termination_Date)'
Declare @Job_Code nvarchar(50) = '$($User.Job_Code)'
Declare @Position_ID nvarchar(50) = '$($User.Position_ID)'
Declare @Position_Title nvarchar(50) = '$($User.Position_Title)'
Declare @Primary_Position nvarchar(50) = '$($User.Primary_Position)'
Declare @Position_Time_Type nvarchar(50) = '$($User.Position_Time_Type)'
Declare @Supervisor_ID nvarchar(50) = '$($User.Supervisor_ID)'
Declare @Supervisor_Name nvarchar(50) = '$($User.Supervisor_Name)'
Declare @Cost_Center nvarchar(50) = '$($User.Cost_Center)'
Declare @Employee_Type nvarchar(50) = '$($User.Employee_Type)'
Declare @Employee_Status nvarchar(50) = '$($User.Employee_Status)'
Declare @Contingent_Worker nvarchar(50) = '$($User.Contingent_Worker)'
Declare @Faculty_Worker nvarchar(50) = '$($User.Faculty_Worker)'
Declare @Retired_Worker nvarchar(50) = '$($User.Retired_Worker)'
Declare @GUID nvarchar(50) = '$($User.GUID)'
Declare @Userid nvarchar(50) = '$($User.Userid)'

IF EXISTS (select employeeID from $table where (employeeID = @Employee_ID) and (employeeType = @Employee_Type) )
	BEGIN
        UPDATE [dbo].[$table]
           SET [employeeID] = @Employee_ID
              ,[firstName] = @First_Name
              ,[lastName] = @Last_Name
              ,[displayName] = @Name
              ,[initials] = @Middle_Name
              ,[streetAddress] = @Work_Address_Line1_Data
              ,[city] = @Work_Municipality
              ,[PostalCode] = @Work_Postal_Code
              ,[personalEmail] = @Home_Email_Address
              ,[OfficePhone] = @Office_Phone
              ,[MobilePhone] = @Mobile_Phone
              ,[RoomNumber] = @Room_Number
              ,[Company] = @Company
              ,[employeeStartDate] = @Hire_Date
              ,[employeeEndDate] = @Termination_Date
              ,[JobCode] = @Job_Code
              ,[PositionID] = @Position_ID
              ,[JobTitle] = @Position_Title
              ,[PositionTime] = @Position_Time_Type
              ,[managerID] = @Supervisor_ID
              ,[manager] = @Supervisor_Name
              ,[CostCenter] = @Cost_Center
              ,[EmployeeType] = @Employee_Type
              ,[EmployeeStatus] = @Employee_Status
              ,[isContingent] = @Contingent_Worker
              ,[isFaculty] = @Faculty_Worker
              ,[isRetired] = @Retired_Worker
              ,[immutableID] = @GUID
              ,[accountName] = @Userid

         WHERE employeeID = @Employee_ID
	END
ELSE
	BEGIN
        INSERT INTO [dbo].[$table]
              ([employeeID]
              ,[firstName]
              ,[lastName]
              ,[displayName]
              ,[initials]
              ,[streetAddress]
              ,[city]
              ,[PostalCode]
              ,[personalEmail]
              ,[OfficePhone]
              ,[MobilePhone]
              ,[RoomNumber]
              ,[Company]
              ,[employeeStartDate]
              ,[employeeEndDate]
              ,[JobCode]
              ,[PositionID]
              ,[JobTitle]
              ,[PositionTime]
              ,[managerID]
              ,[manager]
              ,[CostCenter]
              ,[EmployeeType]
              ,[EmployeeStatus]
              ,[isContingent]
              ,[isFaculty]
              ,[isRetired]
              ,[immutableID]
              ,[accountName])
        VALUES
              (@Employee_ID
              ,@First_Name
              ,@Last_Name
              ,@Name
              ,@Middle_Name
              ,@Work_Address_Line1_Data
              ,@Work_Municipality
              ,@Work_Postal_Code
              ,@Home_Email_Address
              ,@Office_Phone
              ,@Mobile_Phone
              ,@Room_Number
              ,@Company
              ,@Hire_Date
              ,@Termination_Date
              ,@Job_Code
              ,@Position_ID
              ,@Position_Title
              ,@Position_Time_Type
              ,@Supervisor_ID
              ,@Supervisor_Name
              ,@Cost_Center
              ,@Employee_Type
              ,@Employee_Status
              ,@Contingent_Worker
              ,@Faculty_Worker
              ,@Retired_Worker
              ,@GUID
              ,@Userid)
	END
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $sqlCMD
}