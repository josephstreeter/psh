$MAs = $(Get-WmiObject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer"` -computername "." ).name
$Rpt=@()

foreach ($MA in $MAs)
    {
    $MA = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer"`
                          -computername "." -filter "Name='$ma'") 
    if($MA.count -eq 0) {throw "MA not found"}

    $Rpt+=New-Object PSObject -Property @{
        "Name"=$($MA.name)
        "Conn"=$MA[0].NumConnectors().ReturnValue
        "Conn_Total"=$MA[0].NumTotalConnectors().ReturnValue
        "Conn_Expl"=$MA[0].NumExplicitConnectors().ReturnValue
        "DisConn"=$MA[0].NumDisconnectors().ReturnValue
        "DisConn_Total"=$MA[0].NumTotalDisconnectors().ReturnValue
        "DisConn_Filtered"=$MA[0].NumFilteredDisconnectors().ReturnValue
        "DisConn_Expl"=$MA[0].NumExplicitDisconnectors().ReturnValue
        "Exp_Adds"=$MA[0].NumExportAdd().ReturnValue
        "Exp_Deletes"=$MA[0].NumExportDelete().ReturnValue
        "Exp_Updates"=$MA[0].NumExportUpdate().ReturnValue
        "Imp_Adds"=$MA[0].NumImportAdd().ReturnValue
        "Imp_Deletes"=$MA[0].NumImportDelete().ReturnValue
        "Imp_NoChange"=$MA[0].NumImportNoChange().ReturnValue
        "Imp_Updates"=$MA[0].NumImportUpdate().ReturnValue
        "Placeholders"=$MA[0].NumPlaceholders().ReturnValue
         }
    }
$Rpt | Sort name | Select Name,Conn,Conn_Total,Conn_Expl,Disconn,Disconn_Total,Disconn_Filtered,Disconn_Expl,Exp_Adds,Exp_Deletes,Exp_Updates,Imp_Adds,Imp_Deletes,Imp_NoChange,Imp_Updates,Placeholders | ft * -AutoSize #| Out-GridView 
       