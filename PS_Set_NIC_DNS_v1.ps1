$Days = (Get-Date).AddDays(-30)

$DNSServers = "10.39.0.111","10.39.0.112"
$DNSName =    "matc.madison.login"

$Servers = Get-ADComputer -Filter {(operatingSystem -like "*Server*") -and (lastlogondate -gt $days) -and (-not(comment -eq "N"))} -pr ipv4address,comment,lastlogondate 

foreach ($Server in $Servers)
    {
    $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $Server.Name -ea silentlycontinue | where {$_.IPEnabled -eq “TRUE”}

    Foreach($NIC in $NICs) 
        {
        if ($NIC.DNSServerSearchOrder) #  -match "10.39.0.115" 
            {
            Write-Host -ForegroundColor Red $Server.name "Change DNS" $NIC.DNSServerSearchOrder
            $NIC.SetDNSServerSearchOrder() | Out-Null
            $NIC.SetDNSServerSearchOrder($DNSServers) | Out-Null
            $NIC.SetDNSDomain($DNSName) | Out-Null
            } 
        }
    }