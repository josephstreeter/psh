Function Query-SQL($Query)
    {
    $dataSource = "idmdbprd01\MIMStage"
    $SQLuser = "MC-sa"
    $SQLpwd = "MadisonCollege2015_!"
    $database = "StagingDirectory"

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


function Query-ADGroup($Group)
    {
    $Results=Get-ADGroupMember $Group -Server MCDC3
    Return $Results
    }

function Add-ADGroup($Group,$User)
    {
    if ($user){Add-ADGroupMember $Group -members $User}
    Return "$($User.count) added to $Group"
    }

function Remove-ADGroup($Group,$User)
    {
    if ($user){Remove-ADGroupMember $Group -members $User -Confirm:$false}
    Return "$($User.count) removed from $Group"
    }


$Entitlments="(costcenter = 'CC730') and (employeeType = 'A');MC-GS-TS-EMPL1-TS",
             "costcenter = 'CC161';MC-GS-TS-EMPL2-TS"

foreach ($Entitlement in $Entitlments)
    {
    $Query="SELECT * FROM Identities WHERE $($Entitlement.Split(";")[0])"
    $Group=$Entitlement.Split(";")[1]
    
    $population=Query-SQL $Query
    $Members=Query-ADGroup $Group
    
    $UsersAdd=Compare-Object $Members.SamAccountName $population.accountname | ?{$_.sideIndicator -eq "=>"} | select -ExpandProperty inputobject
    $UsersRemove=Compare-Object $Members.SamAccountName $population.accountname | ?{$_.sideIndicator -eq "<="} | select -ExpandProperty inputobject
    
    Add-ADGroup $Group $UsersAdd
    Remove-ADGroup $Group $UsersRemove
    }