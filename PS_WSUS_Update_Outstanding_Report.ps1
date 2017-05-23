   
$Servers = "MCDC2",
"TXDC1",
"DTDC02",
"VDI-DC02",
"MCDC5",
"VDI-DC01",
"MCDC3",
"MDCSYNC",
"MCDC1",
"MCRODC",
"IDMDBPRD01",
"IDMSVCPRD01",
"IDMSYNPRD01",
"ExchangeDAG1",
"EXCHC10",
"EXCHC5",
"EXCHC6",
"EXCHC7",
"EXCHC8",
"EXCHC9",
"EXCHDAG1",
"EXCHDAG2",
"EXCHDAG3",
"EXCHH5",
"EXCHH6",
"EXCHMB01",
"EXCHMB02",
"EXCHMB03",
"EXCHMB5",
"EXCHMB6",
"EXCHMB7",
"EXCHMB8",
"EXCHSMTP1",
"EXCHSMTP2",
"EXCHUM3",
"EXCHUM4",
"BTDEV01",
"BTDEVDB01",
"BTPRD01",
"BTPRDDB01",
"BTTST01",
"ArchMan",
"ADFS01",
"ADFS02",
"FSP01",
"FSP02",
"FSP03",
"DS01",
"DSSQL"


$Array=@()

foreach ($Server in $Servers)
    {
    $Rpt = Invoke-Command -ComputerName $Server -argumentlist $Server -scriptblock `
        {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0")

        $Results=@()
        foreach ($Update in $SearchResult.Updates)
            {
            $Results+=New-Object psobject -Property @{
                "Server"=$Args[0]
                "Title"=$Update.Title
                "Description"=$Update.Description
                "EULAAccepted"=$Update.EulaAccepted
                "Downloaded"=$Update.IsDownloaded
                "RebootRequired"=$Update.RebootRequired 
                } `
            } 
        $Results
        }
    $Array += $Rpt
    }
$Array | ft Server,Title,RebootRequired -AutoSize