$Server = "dhcpprd01"

Function Create-Resevation
    {
    Get-DhcpServerV4Lease -ComputerName $Server -IPAddress 10.122.76.41 | Add-DhcpServerv4Reservation -ComputerName $Server
    }

$Leases = Get-DhcpServerv4Scope -ComputerName $Server | % {Get-DhcpServerv4Lease -ComputerName $Server -ScopeId $_.ScopeId}
$Leases | group addressstate | sort count | ft name,count -AutoSize

Get-DhcpServerv4Scope -ComputerName $Server | Get-DhcpServerv4Lease -ComputerName $Server -BadLeases

Get-DhcpServerv4ScopeStatistics -ComputerName $Server | where {$_.PercentageInUse -gt 70} | ft ScopeID,Free,InUse,PercentageInUse -AutoSize