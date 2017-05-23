
$MAs = $(Get-WmiObject `
            -class "MIIS_ManagementAgent" `
            -namespace "root\MicrosoftIdentityIntegrationServer" `
            -computername "." ).name

$Rpt=@()

foreach ($MA in $MAs)
    {
    $MA = @(get-wmiobject ` 
                -class "MIIS_ManagementAgent" `
                -namespace "root\MicrosoftIdentityIntegrationServer" `
                -computername "." `
                -filter "Name='$ma'") 

    if($MA.count -eq 0) {throw "MA not found"}

    $Rpt+=New-Object PSObject -Property @{
         "Name"=$($MA.name)
         "Update"=$($MA[0].NumExportUpdate().ReturnValue)
         "Add"=$($MA[0].NumExportAdd().ReturnValue)
         "Delete"=$($MA[0].NumExportDelete().ReturnValue)
         }
    }

$Rpt | Sort name | ft Name,Add,Update,Delete -AutoSize