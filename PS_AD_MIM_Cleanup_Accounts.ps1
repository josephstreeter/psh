$Users = gc C:\Scripts\Bad_Accounts_emplnum.txt

Function Query-SQL($Query,$Server,$DataBase)
    {
    $dataSource = $Server
    $SQLuser = "sa"
    $SQLpwd = "MadisonCollege2015_!"
    $database = $database

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connectionString = "Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=true;"
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()
    $SQLTable = new-object "System.Data.DataTable"
    $SQLTable.Load($result)
    $connection.Close()

    Return $SQLTable
    }

Function Connect-AD($Name,$Username,$Domain)
	{
	if (-not (get-psdrive $Name -ea silentlycontinue)) 
	    {
	    New-PSDrive `
	        –Name $Name `
	        -Server "$Domain" `
	        –PSProvider ActiveDirectory `
	        -Credential $(Get-Credential $Username) `
	        -Root "//RootDSE/" `
	        -Scope Global
	    }
	    Else
	    {
	    Write-Host -ForegroundColor Green "$Domain already exists"
	    }
	}

foreach ($Delete in $Users)
    {
    #Get-ADUser -Filter {employeeNumber -eq $Delete} -pr employeeNumber | select -ExpandProperty employeeNumber
    #Query-SQL "SELECT employeeNumber FROM Identities WHERE EmployeeNumber = '$Delete'" "idmdbprd01\mimstage" "stagingdirectory" | select -ExpandProperty employeeNumber
    #Remove-ADUser $account -Confirm:$false -ea SilentlyContinue
    #Query-SQL "DELETE FROM Identities WHERE AccountName = '$account'" "idmdbprd01\mimstage" "stagingdirectory"
    
    if (-not(Get-PSDrive DMZ))
        {
        Connect-AD "DMZ" "MC\Jstreeter_a" "directory.madisoncollege.edu"
        }
    "`n############ `n"
    "Delete DMZ User:`t" + $(Get-ADUser -Filter {employeeNumber -eq $Delete} -pr employeeNumber -Server directory.madisoncollege.edu | select -ExpandProperty employeeNumber)
    "Delete AD User:`t" + $(Get-ADUser -Filter {employeeNumber -eq $Delete} -pr employeeNumber -Server MATC.Madison.Login | select -ExpandProperty employeeNumber)
    "Delete Stage User:`t" + $(Query-SQL "SELECT * FROM Identities WHERE employeeNumber = '$Delete'" "idmdbprd01\mimstage" "stagingdirectory" | select -ExpandProperty employeeNumber)
    "Delete PWM:`t" + $(Query-SQL "SELECT * FROM PWM_Responses WHERE id = '$Delete'" "idmdbprd01\mimstage" "pwm" | select -ExpandProperty employeeNumber)
    }



