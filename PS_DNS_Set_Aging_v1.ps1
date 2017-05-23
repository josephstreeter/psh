
$zones = Get-DnsServerZone -ComputerName txdc1 | ? {($_.IsReverseLookupZone -eq $True) -and ($_.IsDsIntegrated -eq $True)}
    
foreach ($zone in $zones) 
    {
    #Get-DnsServerZoneAging -ComputerName txdc1 -Name $zone.zonename
    Set-DnsServerZoneAging -ComputerName txdc1 -Name $zone.zonename -RefreshInterval 4.00:00:00 -NoRefreshInterval 4.00:00:00
    }
