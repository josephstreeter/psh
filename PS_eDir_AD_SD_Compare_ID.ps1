$Uid = Read-Host "Enter EDirectory Username"
$pwd = Read-Host "Enter LDAP Password" -AsSecureString
$ADUser = Read-Host "Enter AD Username"
$ADpwd = Read-Host "Enter LDAP Password" -AsSecureString

$Name = Read-Host "Enter Username to query"

$PropArray = @()

Add-Type -AssemblyName System.DirectoryServices

$EDPath = "LDAP://10.39.0.205:389/o=matc"
$EDUser = "cn=$UID,ou=users,o=matc"
$EDPWD  = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($pwd))
$EDAuthType = 'None' #(Equates to basic)

$Root = New-Object System.DirectoryServices.DirectoryEntry -argumentlist $EDPath,$EDUser,$EDPWD,$EDAuthType
$Query = New-Object System.DirectoryServices.DirectorySearcher
$Query.SearchRoot = $Root
$Query.Filter = "(&(cn=$Name))"
$EDSearchResults = $Query.FindAll()

#$EDSearchResults.Properties

$ADPath = "LDAP://txdc1.matc.madison.login/dc=matc,dc=madison,dc=login"
$ADPWD  = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($ADpwd))
$ADAuthType = 'None' #(Equates to basic)

$Root = New-Object System.DirectoryServices.DirectoryEntry -argumentlist $ADPath,$ADUser,$ADPWD #,$ADAuthType
$Query = New-Object System.DirectoryServices.DirectorySearcher
$Query.SearchRoot = $Root
$Query.Filter = "(&(samaccountname=$Name))"
$ADSearchResults = $Query.FindAll()


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

$connection.Close()


$dataSource = “IDMDBPRD01.matc.madison.login\MIMStage”
$SQLuser = “sa”
$SQLpwd = "MadisonCollege2015_!"
$database = “PWM”
$connectionString = “Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=False;”
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$query = “SELECT * FROM PWM_RESPONSES WHERE id = '$($ADSearchResults.Properties.employeenumber)'”

$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()
$PWtable = new-object “System.Data.DataTable”
$PWtable.Load($result)

$connection.Close()

$dataSource = “IDMDBPRD01.matc.madison.login\MIMSync”
$SQLuser = “sa”
$SQLpwd = "MadisonCollege2015_!"
$database = “FIMSynchronization”
$connectionString = “Server=$dataSource;uid=$SQLuser;pwd=$SQLpwd;Database=$database;Integrated Security=False;”
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$query = “SELECT * FROM mms_metaverse WHERE AccountName = '$name'”

$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()
$MVtable = new-object “System.Data.DataTable”
$MVtable.Load($result)

$connection.Close()


$PropArray += New-object PSObject -Property @{
    "Directory" = "AD"
    "UserID" = $($ADSearchResults.Properties.samaccountname)
    "FirstName" = $($ADSearchResults.Properties.givenname)
    "LastName" = $($ADSearchResults.Properties.sn)
    "EmployeeID" = $($ADSearchResults.Properties.employeeid)
    "EmployeeNumber" = $($ADSearchResults.Properties.employeenumber)
     }

$PropArray += New-object PSObject -Property @{
    "Directory" = "ED"
    "UserID" = $($EDSearchResults.Properties.cn)
    "FirstName" = $($EDSearchResults.Properties.givenname)
    "LastName" = $($EDSearchResults.Properties.sn)
    "EmployeeID" = $($EDSearchResults.Properties.workforceid)
    "EmployeeNumber" = $($EDSearchResults.Properties.accesscardnumber)
     }

$PropArray += New-object PSObject -Property @{
    "Directory" = "SD"
    "UserID" = $($SDtable.accountname)
    "FirstName" = $($SDtable.firstname)
    "LastName" = $($SDTable.lastname)
    "EmployeeID" = $($SDtable.employeeID)
    "EmployeeNumber" = $($SDtable.employeeNumber)
     }

$PropArray += New-object PSObject -Property @{
    "Directory" = "PWM"
    "UserID" = "NA"
    "FirstName" = "NA"
    "LastName" = "NA"
    "EmployeeID" = "NA"
    "EmployeeNumber" = $($PWtable.id)
     }

$PropArray += New-object PSObject -Property @{
    "Directory" = "MV"
    "UserID" = $($MVtable.accountname)
    "FirstName" = $($MVtable.firstname)
    "LastName" = $($MVTable.lastname)
    "EmployeeID" = $($MVtable.employeeID)
    "EmployeeNumber" = $($MVtable.employeeNumber)
     }
     
$PropArray | ft Directory,UserID,FirstName,LastName,EmployeeID,EmployeeNumber -AutoSize 


