Function Query-SD($Name)
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

    Return $SDtable

    $connection.Close()
    }

Function Query-AD($Name)
    {
    $User = Get-ADUser -f {sAMAccountName -eq $Name} -pr employeeID,employeeNumber,employeeType,LastLogonDate,whencreated | select name,sAMAccountName,employeeID,employeeNumber,employeeType,LastLogonDate,whencreated
    Return $User 
    }

Function Create-AD($Name)
    {
    [string]$Upn = $Name.accountName + "@madisoncollege.edu"
    $PassWord = ConvertTo-SecureString "123Madison456College789_!" -AsPlainText -Force
    Switch($Name.employeeType)
        {
        "A" {"OU=Admin,OU=FacStaff,DC=MATC,DC=Madison,DC=Login"}
        "C" {"OU=NonEmployee,DC=MATC,DC=Madison,DC=Login"}
        "E" {"OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=Login"}
        "F" {"OU=Faculty,OU=FacStaff,DC=MATC,DC=Madison,DC=Login"}
        "I" {"OU=TechServices,OU=FacStaff,DC=MATC,DC=Madison,DC=Login"}
        }
    
    
    New-ADUser $Name.AccountName `
        -Path "OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=Login" `
        -AccountPassword($PassWord) `
        -sAMAccountName $Name.AccountName `
        -UserPrincipalName $Upn `
        -GivenName $Name.FirstName `
        -Surname $Name.LastName `
        -employeeID $Name.employeeID `
        -employeeNumber $Name.employeeNumber `
        -Enabled $True `
        -OtherAttributes @{employeeType=$Name.employeeType}
    }

$Users = "ambaghkhanian","mmlettman","zmelgarejopinto","crfrakes"

foreach ($User in $Users)
    {
    $SDUser = Query-SD $User
    $SDUser | ft name,employeeType
    #Create-AD $SDUser
    }
