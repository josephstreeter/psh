Function Query-SQL($Value)
    {
    $dataSource = "idmdbprd01\MIMStage"
    $SQLuser = "SA"
    $SQLpwd = "MadisonCollege2015_!"
    $database = "StagingDirectory"

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connectionString = "Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=False;"
    $connection.ConnectionString = $connectionString
    $connection.Open()

    $query = "SELECT * FROM identities WHERE (employeestatus <> 'D') and (employeeType <> 'S') and (accountName IS NOT NULL)"
    
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()
    $SQLTable = new-object "System.Data.DataTable"
    $SQLTable.Load($result)
    $connection.Close()

    Return $SQLTable
    }


Function Query-AD($Name)
    {
    $Result = Get-ADUser -f {sAMAccountName -eq $Name}
    Return $Result
    }

Function Create-ADUser($User)
    {
    $Path = Get-OUPath $User
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
        -OtherAttributes @{carlicense="pwmNewAccount";employeeType=$user.employeeType} `

    Set-ADAccountControl $User.accountName -PasswordNeverExpires $true
    }

Function Get-OUPath($User)
    {
    Switch ($User.employeeType)
        {
        "A" {$Path="ou=admin,ou=facstaff,DC=MATC,DC=Madison,DC=Login"}
        "C" {$Path="ou=nonEmployee,DC=MATC,DC=Madison,DC=Login"}
        "E" {$Path="ou=Staff,ou=facstaff,DC=MATC,DC=Madison,DC=Login"}
        "F" {$Path="ou=faculty,ou=facstaff,DC=MATC,DC=Madison,DC=Login"}
        "I" {$Path="ou=TechServices,ou=facstaff,DC=MATC,DC=Madison,DC=Login"}
        "S" {$Path="OU=Users,OU=Student,DC=MATC,DC=Madison,DC=Login"}
        }
    Return $Path 
    }

    "Query Stage"
    $Users = Query-SQL
    $Users.Count

    "Query AD"
    foreach ($user in $users)
        {
        if (Query-AD $($User.AccountName))
            {
            #$user.accountName + " Exists"
            }
            Else
            {
            if (Create-ADUser($User))
                {
                "Created $($User.accountName) $($User.employeeType) $($User.employeeStatus)"
                }
                Else
                {
                "Failed Creating $($User.accountName) $($User.employeeType) $($User.employeeStatus)"
                }
            }
        }