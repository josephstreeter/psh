$DCs = Get-ADDomainController -Filter *

Foreach ($DC in $DCs) 
    {
    #
    $Zones = (Get-DnsServer -ComputerName $DC.hostname).serverzone 
    #$Zones | % {Set-DnsServerZoneAging -ComputerName $DC.hostname -Aging $false -Name $_.zonename}
    $Zones | % {Get-DnsServerZoneAging -ComputerName $DC.HostName -name $_.zonename -WarningAction SilentlyContinue -ErrorAction SilentlyContinue} | ft -AutoSize
    }