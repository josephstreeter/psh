$rep = repadmin /showrepl * /csv
$Results = $rep | ConvertFrom-Csv 

$Report = @()

Foreach ($result in $results) {

    $Report += New-object PSObject -Property @{
        "Dest" = $Result.'Destination DSA'
        "DestSite" = $Result.'Destination DSA Site'
        "NamingContext" = $Result.'Naming Context'
        "SourceSite" = $Result.'Source DSA Site'
        "Source" = $Result.'Source DSA'
        "Transport" = $Result.'Transport Type'
        "NumberFailures" = $Result.'Number of Failures'
        "LastFailureTime" = $Result.'Last Failure Time'
        "LastSuccessTime" = $Result.'Last Success Time'
        "LastFailureStatus" = $Result.'Last Failure Status'
        }
    }

$Report | select "Source","SourceSite","Dest","DestSite","NumberFailures","LastFailureTime","LastFailureStatus","LastSuccessTime","Transport","NamingContext" | ft -AutoSize
