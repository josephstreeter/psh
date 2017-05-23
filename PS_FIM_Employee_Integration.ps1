Clear-Host
[xml]$xml = gc C:\scripts1\INT056A_Cognos_Worker_20150828020012.xml

$Count = ($xml.Worker_Sync.Worker).count
$i=0
$PropArray = @()

foreach ($User in $($xml.Worker_Sync.Worker)) {
    #Clear-Host
    write-progress -activity "Gathering Data" -status "Progress:" -percentcomplete (($i/$Count)*100)
    
    $EmplID     = $xml.Worker_Sync.Worker[$i].Summary.employee_ID
    $Name       = $xml.Worker_Sync.Worker[$i].Summary.name
    $Phone      = $xml.Worker_Sync.Worker[$i].Personal.Phone_Data.Formatted_Phone_Number
    $Email      = $xml.Worker_Sync.Worker[$i].Personal.Email_Data.Email_Address
    $Status     = $xml.Worker_Sync.Worker[$i].Status.Employee_Status
    $ActiveDate = $xml.Worker_Sync.Worker[$i].Status.Active_Status_Date
    $HireDate   = $xml.Worker_Sync.Worker[$i].Status.Hire_Date
    $EndDate    = $xml.Worker_Sync.Worker[$i].Status.End_Employment_Date
    $Title      = $xml.Worker_Sync.Worker[$i].Position.Business_Title
    $Type       = $xml.Worker_Sync.Worker[$i].Position.Worker_Type
    $Department = $xml.Worker_Sync.Worker[$i].Additional_Information.Cost_Center_Name
    $Location   = $xml.Worker_Sync.Worker[$i].Position.Business_Site_Name
    $Supervisor = $xml.Worker_Sync.Worker[$i].Position.Supervisor_ID
    $Room       = $xml.Worker_Sync.Worker[$i].Additional_Information.Worker_Room

    $Prop = New-Object System.Object 
    $Prop | Add-Member -type NoteProperty -name EmplID     -value $EmplID
    $Prop | Add-Member -type NoteProperty -name Name       -value $(if ($Name){($Name).replace("[C]","").Split("(")[0]})
    $Prop | Add-Member -type NoteProperty -name Phone      -value $(if ($Phone) {($Phone -replace "\+1","" -replace "\(","" -replace "\) ","." -replace "-",".").Split("x")[0].trim()})
    $Prop | Add-Member -type NoteProperty -name Email      -value $(if ($Email) {$Email.tolower() | select -first 1 | ? {$_ -match "@madisoncollege.edu"}})
    $Prop | Add-Member -type NoteProperty -name Status     -value $Status
    $Prop | Add-Member -type NoteProperty -name ActiveDate -value $ActiveDate
    $Prop | Add-Member -type NoteProperty -name HireDate   -value $HireDate
    $Prop | Add-Member -type NoteProperty -name EndDate    -value $EndDate
    $Prop | Add-Member -type NoteProperty -name Title      -value $Title
    $Prop | Add-Member -type NoteProperty -name Department -value $Department
    $Prop | Add-Member -type NoteProperty -name Type       -value $Type
    $Prop | Add-Member -type NoteProperty -name Location   -value $Location
    $Prop | Add-Member -type NoteProperty -name Supervisor -value $Supervisor
    $Prop | Add-Member -type NoteProperty -name Room       -value $Room
    $PropArray += $Prop
    $i++
    }

$PropArray | ? {$_.status -eq "Active" } | ft Name,EmplID,Email,Phone,Status,Title,Department,Type,Location,supervisor,Room -AutoSize
$PropArray | ? {$_.status -eq "Active" } | group type | select name,count | ft -AutoSize
$PropArray | ? {$_.status -eq "Active" } | group Department | select name,count | ft -AutoSize