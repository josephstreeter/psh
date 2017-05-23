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

function Query-ADGroup($Name,$Desc,$Display)
    {
    $Results=Get-ADGroup -Filter {name -eq $Name} -ea 0
    if (-not($Results))
        {
        New-ADGroup `
            -Name $Name `
            -SamAccountName $Name `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName $Display `
            -Path "OU=Groups,OU=Managed,OU=MC,DC=MATC,DC=Madison,DC=Login" `
            -Description $Desc 
        }
    }

function Query-ADMember($Group)
    {
    $Results=Get-ADGroupMember $Group -Server MCDC3
    Return $Results
    }

function Add-ADMember($Group,$User)
    {
    if ($user){Add-ADGroupMember $Group -members $User -Server MCDC3}
    Return "$($User.count) added to $Group"
    }

function Remove-ADMember($Group,$User)
    {
    if ($user){Remove-ADGroupMember $Group -members $User -Confirm:$false}
    Return "$($User.count) removed from $Group"
    }

function Get-ADMemberDelta($Members,$population)
    {    
    if ($members)
        {
        $UsersAdd=Compare-Object $Members.SamAccountName $population.accountname | ?{$_.sideIndicator -eq "=>"} | select -ExpandProperty inputobject
        $UsersRemove=Compare-Object $Members.SamAccountName $population.accountname | ?{$_.sideIndicator -eq "<="} | select -ExpandProperty inputobject
        }
    Else
        {
        $UsersAdd=$population|select -ExpandProperty accountname
        }
    Add-ADMember $Name $UsersAdd
    Remove-ADMember $Name $UsersRemove
    }
<#
Create and manage groups based on Cost Center
#>
$Depts=Query-SQL "SELECT DISTINCT [costCenter],[department] FROM [StagingDirectory].[dbo].[Identities] WHERE employeeType <> 'S' ORDER BY costCenter"

foreach ($Dept in $Depts)
    {
    $CostCenter=$Dept.costcenter
    $Department=$Dept.department
    
    "############# $CostCenter   $Department #######################"
    
    $Name="MC-GS-$($Dept.costCenter)-ts"
    $Display="$($Dept.Department) - ($($Dept.costCenter))"
    $Desc="$($Dept.Department) - ($($Dept.costCenter))"

    #$population=Query-SQL "SELECT accountname FROM Identities WHERE costCenter = '$($CostCenter)'"
    $Members=Query-ADMember $Name


    Query-ADGroup $Name $Desc $Display
    Get-ADMemberDelta $(Query-ADMember $Name) $(Query-SQL "SELECT accountname FROM Identities WHERE costCenter = '$($CostCenter)'")
    }


<#
Create and manage groups based on EmployeeType
#>

$Groups=@("Query,Name,Description,DisplayName
(employeeStatus = 'A') and (EmployeeType = 'A'),MC-GS-Employees-Admin,Employees Administrative,MC Employees Administrators
(employeeStatus = 'A') and (EmployeeType = 'E'),MC-GS-Employees-Staff,Employees Staff,MC Employees Staff
(employeeStatus = 'A') and (EmployeeType = 'C'),MC-GS-Employees-Consultant,Employees Consultant, MC Employees Consultant
(employeeStatus = 'A') and (isRetired = 'True'),MC-GS-Employees-Retired,Employees Retired,MC Employees Retired
(employeeStatus = 'A') and (EmployeeType = 'F') and (positionTime = 'Full_Time'),MC-GS-Employees-Faculty-Fulltime,Employees Faculty Full Time,MC Employees-Faculty Full Time
(employeeStatus = 'A') and (EmployeeType = 'F') and (positionTime = 'Part_Time'),MC-GS-Employees-Faculty-Parttime,Employees Faculty Part Time,MC Employees-Faculty Part Time
") | ConvertFrom-Csv

foreach ($Group in $Groups)
    {
    "############## $($Group.Description) ###########################`n`n"
    
    $Name=$Group.name
    $Display=$Group.displayName
    $Desc=$Group.Description

    $Members=Query-ADMember $Name

    Query-ADGroup $Name $Desc $Display
    Get-ADMemberDelta $(Query-ADMember $Name) $(Query-SQL "SELECT accountName,EmployeeID,EmployeeNumber,EmployeeType,EmployeeStatus FROM Identities WHERE $($Group.Query)")
    }


<#
Create and manage groups based on Employee Location
#>

$Groups=@("Query,Name,Description,DisplayName
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL03'),MC-GS-Employees-Madison-Comm-Ave,Madison College Commercial Ave Employees,MC Commercial Ave Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL02'),MC-GS-Employees-Madison-Downtown,Madison College Downtown Employees,MC Downtown Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL30'),MC-GS-Employees-Ft-Atkinson,Madison College Fort Atkinson Employees,MC Fort Atkinson Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL15'),MC-GS-Employees-Portage,Madison College Portage Employees,MC Portage Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL15'),MC-GS-Employees-Reedsburg,Madison College Reedsburg Employees,MC Reedsburg Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL15'),MC-GS-Employees-Madison-South,Madison College Madison South Employees,MC Madison South Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL15'),MC-GS-Employees-Madison-Truax,Madison College Madison Truax Employees,MC Madison Truax Employees
(employeeStatus = 'A') and (EmployeeType = 'E') and (officeLocationCode = 'CCL15'),MC-GS-Employees-Madison-West,Madison College Madison West Employees,MC Madison West Employees
") | ConvertFrom-Csv

foreach ($Group in $Groups)
    {
    "`n`n############## $($Group.Description) ###########################"
    
    $Name=$Group.name
    $Display=$Group.displayName
    $Desc=$Group.Description

    $Members=Query-ADMember $Name

    Query-ADGroup $Name $Desc $Display
    Get-ADMemberDelta $(Query-ADMember $Name) $(Query-SQL "SELECT accountName,EmployeeID,EmployeeNumber,EmployeeType,EmployeeStatus FROM Identities WHERE $($Group.Query)")
    }


<#
Create and manage groups for SDS


$Groups=@("'Query,Name,Description,DisplayName
    ((employeeType = 'E') or (employeeType = 'A')) 
	and (employeeStatus = 'A')
	or (costCenter = 'CC105')
	or (costCenter = 'CC656')
	or (costCenter = 'CC300')
	or (costCenter = 'CC314')
	or (costCenter = 'CC315')
	or (costCenter = 'CC321')
	or (costCenter = 'CC322')
	or (costCenter = 'CC323')
	or (costCenter = 'CC324')
	or (costCenter = 'CC325')
	or (costCenter = 'CC332')
	or (costCenter = 'CC333')
	or (costCenter = 'CC334')
	or (costCenter = 'CC335')
	or (costCenter = 'CC336')
	or (costCenter = 'CC338')
	or (costCenter = 'CC339')
	or (costCenter = 'CC655')
	or (costCenter = 'CC341')
	or (costCenter = 'CC337')',MC-GS-Employees-SDS,Madison College SDS Employees,MC Madison SDS Employees
    '(employeeStatus = 'A')
    and ((costCenter = 'CC730')
	or (costCenter = 'CC656')
	or (costCenter = 'CC300')
	or (costCenter = 'CC314')
	or (costCenter = 'CC315')
	or (costCenter = 'CC321')
	or (costCenter = 'CC322')
	or (costCenter = 'CC323')
	or (costCenter = 'CC324')
	or (costCenter = 'CC325')
	or (costCenter = 'CC332')
	or (costCenter = 'CC333')
	or (costCenter = 'CC334')
	or (costCenter = 'CC335')
	or (costCenter = 'CC336')
	or (costCenter = 'CC338')
	or (costCenter = 'CC339')
	or (costCenter = 'CC655')
	or (costCenter = 'CC341')
	or (costCenter = 'CC337'))
	and
	((jobCode<>300310)
	and (jobCode<>300392)
	and (jobCode<>300410)
	and (jobCode<>300417)
	and (jobCode<>300418)
	and (jobCode<>300265)
	and (jobCode<>300314)
	and (jobCode<>300206)
	and (jobCode<>300399)
	and (jobCode<>300398)
	and (jobCode<>300397)
	and (jobCode<>300396))',MC-GS-Employees-SDS,Madison College SDS Leadership,MC Madison SDS Leadership
    ") | convertfrom-csv

foreach ($Group in $Groups)
    {
    "`n`n############## $($Group.Description) ###########################"
    
    $Name=$Group.name
    $Display=$Group.displayName
    $Desc=$Group.Description

    $Members=Query-ADMember $Name

    Query-ADGroup $Name $Desc $Display
    Get-ADMemberDelta $(Query-ADMember $Name) $(Query-SQL "SELECT accountName,EmployeeID,EmployeeNumber,EmployeeType,EmployeeStatus FROM Identities WHERE $($Group.Query)")
    }
#>