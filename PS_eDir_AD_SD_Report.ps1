Function Get-Errors 
    {
    [xml]$xml = gc .\ADMA-Errors.xml
    $entries = $xml.'run-history'.'run-details'.'step-details'.'synchronization-errors'.'export-error'.dn
    Return $entries
    }

Function Get-ADObjects($Name) {
    Get-ADUser -f {sAMAccountName -eq $Name} -pr employeeID,employeeNumber,employeeType,LastLogonDate,whencreated | select name,sAMAccountName,employeeID,employeeNumber,employeeType,LastLogonDate,whencreated
    } 

Function Get-SDObjects($name) 
    {
    $dataSource = “IDMDBPRD01.matc.madison.login\MIMStage”
    $SQLuser = “sa”
    $SQLpwd = "MadisonCollege2015_!"
    $database = “StagingDirectory”
    $connectionString = “Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=False;”
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    $query = “SELECT * FROM identities WHERE AccountName = '$name'”

    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()
    $SDtable = new-object “System.Data.DataTable”
    $SDtable.Load($result)

    Return $SDTable
    
    $connection.Close()
    }

$PropArray=@()
$objects = Get-Errors

foreach ($object in $objects)
    {
    $Name = $($object.Split(",")[0].replace("CN=",""))
    $AD = Get-ADObjects $Name
    $SD = Get-SDObjects $Name
    
    If ($AD)
        {
        $PropArray += New-object PSObject -Property @{
            "Name" = $($Name)
            "Name_AD" = $($AD.name)
            "UserID_AD" = $($AD.samaccountname)
            "EmplID_AD" = $($AD.employeeid)
            "EmplNum_AD" = $($AD.employeenumber)
            "EmplType_AD" = $($AD.employeeType)
            "EmplType_SD" = $($SD.employeeType)
            "UserID_SD" = $($SD.accountname)
            "EmplID_SD" = $($SD.employeeid)
            "EmplNum_SD" = $($SD.employeenumber)
            }
        }
    }

$PropArray | Select Name_AD,Name,UserID_AD,UserID_SD,EmplID_AD,EmplID_SD,EmplType_AD,EmplType_SD,EmplNum_AD,EmplNum_SD | ConvertTo-Csv | Out-File C:\Scripts\error_report.csv
$PropArray | sort Name_AD | Select Name_AD,UserID_AD,UserID_SD,EmplID_AD,EmplID_SD,EmplType_AD,EmplType_SD,EmplNum_AD,EmplNum_SD | ft -AutoSize