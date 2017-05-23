Function Get-SD($Name)
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

Function Get-AD($Name)
    {
    $User = Get-ADUser -f {sAMAccountName -eq $Name} -pr employeeID,employeeNumber,employeeType,LastLogonDate,whencreated | select name,sAMAccountName,employeeID,employeeNumber,employeeType,LastLogonDate,whencreated
    Return $User 
    }

Function Get-ED($Name)
    {
    $UID = 'JStreeter'
    If (-not($pwd))
        {
        $pwd = Read-Host "Enter LDAP Password" -AsSecureString
        }

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

    Return $EDSearchResults.Properties
    }

$PropArray = @()

foreach ($name in $(get-aduser -Filter {(employeeType -like "*")-and(samaccountname -like "*")} -SearchBase "OU=EmailOnly,DC=MATC,DC=Madison,DC=Login"))
    {
    $ED = Get-ED $Name.sAMAccountName
    $AD = Get-AD $Name.sAMAccountName
    $SD = Get-SD $Name.sAMAccountName


    If ($AD)
        {
        $PropArray += New-object PSObject -Property @{
            "Name" = $($Name)
            "Name_AD" = $($AD.name)
            "UserID_AD" = $($AD.samaccountname)
            "UserID_ED" = $($ED.cn)
            "UserID_SD" = $($SD.accountname)
            "EmplID_AD" = $($AD.employeeid)
            "EmplID_ED" = $($ED.workforceid)
            "EmplID_SD" = $($SD.employeeid)
            "EmplNum_AD" = $($AD.employeenumber)
            "EmplNum_ED" = $($ED.accesscardnumber)
            "EmplNum_SD" = $($SD.employeenumber)
            "EmplType_AD" = $($AD.employeeType)
            "EmplType_SD" = $($SD.employeeType)
            "UserID" = if ($AD.samaccountname -eq $ED.cn -eq $SD.accountname){"True"}Else {"False"}
            "EmplID" = if ($AD.employeeid -eq $ED.workforceid -eq $SD.employeeid){"True"} Else {"False"}
            "EmplNUm" = if ($AD.employeenumber -eq $ED.accesscardnumber -eq $SD.accountname){"True"} Else {"False"}
            "EmplType" = if ($AD.employeeType -eq $SD.employeeType){"True"} Else {"False"}
            }
        }
    }
#$PropArray | Select Name_AD,UserID_AD,UserID_ED,UserID_SD,EmplID_AD,EmplID_ED,EmplID_SD,EmplType_AD,EmplType_SD,EmplNum_AD,EmplNum_ED,EmplNum_SD,UserID,EmplID,EmplType,EmplNum | ft * -AutoSize
#$PropArray | Select Name_AD,UserID,EmplID,EmplType,EmplNum | ft * -AutoSize
$PropArray | Select Name_AD,UserID_AD,UserID_ED,UserID_SD,EmplID_AD,EmplID_ED,EmplID_SD,EmplType_AD,EmplType_SD,EmplNum_AD,EmplNum_ED,EmplNum_SD,UserID,EmplID,EmplType,EmplNum | ConvertTo-Csv | out-file \\idmdbprd01\source\wtf_just_happened_email.csv