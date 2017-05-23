Function Query-SQL($Attrib,$Value)
    {
    $dataSource = "idmdbprd01\MIMStage"
    $SQLuser = "SA"
    $SQLpwd = "MadisonCollege2015_!"
    $database = "StagingDirectory"

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connectionString = "Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=False;"
    $connection.ConnectionString = $connectionString
    $connection.Open()

    $query = "SELECT * FROM identities WHERE ($Attrib = '$Value') AND (AccountName <> '')"
    
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()
    $SQLTable = new-object "System.Data.DataTable"
    $SQLTable.Load($result)
    $connection.Close()

    Return $SQLTable
    }

Function Create-ADUser($User)
    {
    cd PRDD:
    $Path = "OU=Student,OU=Users,OU=Managed,DC=madisoncollege,DC=edu"
    New-ADUser `
        -AccountPassword (ConvertTo-SecureString “MyMadisonCollegePassowrd10001)!” -AsPlainText -Force) `
        -ChangePasswordAtLogon $false `
        -City $User.city `
        -company $User.company `
        -DisplayName ($User.lastName +“, ” + $User.firstName) `
        -Enabled $true `
        -Name $User.accountName `
        -SamAccountName $User.accountName `
        -Path $Path `
        -givenname $User.firstName `
        -surname $User.lastName `
        -userprincipalname ($User.accountName + “@madisoncollege.edu”) `
        -department $User.department `
        -EmployeeID $User.employeeID `
        -EmployeeNumber $User.employeeNumber `
        -PassThru
        

    Set-ADAccountControl $User.accountName -PasswordNeverExpires $true
    }

$Users = Query-SQL employeeType S

foreach ($user in $users)
    {
    [string]$UserID = $User.accountName
    cd PRDD:
    try {$Test=Get-ADUser -f {name -eq $UserID}}
    catch {"$($User.accountName) $($User.employeeNumber)"}
    if ($Test)
        {
        #$User.accountName
        }
    Else
        {
        cd PRDD:
        Create-ADUser $User
        }
    }
