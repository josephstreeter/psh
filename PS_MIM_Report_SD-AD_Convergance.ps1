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

    $query = "SELECT * FROM identities WHERE accountName = '$Value'"
    
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
    $Result = Get-ADUser -f {sAMAccountName -eq $Name} -pr *
    Return $Result
    }

Function Get-DN($User)
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

$Rpt=@()
foreach ($userID in $Users.accountName)
    {
    $ID = Query-SQL $UserID
    $User = Query-AD $UserID
    #"CN="+$ID.accountname +","+ $(Get-DN $id) + " " + $User.DistinguishedName
    $Rpt+=New-Object PSObject -Property @{
        "ID"=$ID.accountName
        "Location"="CN="+$ID.accountname +","+$(Get-DN $id) -eq $User.DistinguishedName
        "UserID"=$id.accountName -eq $User.sAMAccountName 
        "Email"=$id.email -eq $User.mail 
        "EmplID"=$id.employeeID -eq $User.employeeID 
        "EmplNum"=$id.employeeNumber -eq $User.employeeNumber 
        "EmplType"=$id.employeeType -eq $User.employeeType 
        "FirstName"=$id.firstName -eq $User.givenName 
        "Initials"=$id.initials -eq $User.initials 
        "LastName"=$id.lastName -eq $User.surName
        }
    }
#$rpt | sort ID | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize

"`nIncorrect EmployeeType"
"-------------------------"
$rpt | sort ID | ? {$_.emplType -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
"`nIncorrect EmployeeID"
"----------------------"
$rpt | sort ID | ? {$_.emplID -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
"`nIncorrect EmployeeNumber"
"--------------------------"
$rpt | sort ID | ? {$_.emplNum -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
#"`nIncorrect Email"
#"-----------------"
#$rpt | sort ID | ? {$_.email -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
"`nIncorrect First Name"
"----------------------"
$rpt | sort ID | ? {$_.FirstName -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
"`nIncorrect Last Name"
"---------------------"
$rpt | sort ID | ? {$_.LastName -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize
"`nIncorrect Location"
"--------------------"
$rpt | sort ID | ? {$_.Location -eq $false} | ft ID,FirstName,LastName,Email,EmplType,EmplID,EmplNum,Location -AutoSize