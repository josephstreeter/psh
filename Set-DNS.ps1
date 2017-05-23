Param ([string]$net,[string]$servers)

Switch ($net) { 
    "home" {Set-DnsClientServerAddress -Interfacealias "vEthernet (External)" -ServerAddresses ("192.168.0.15", "192.168.0.16")}
    "other" {Set-DnsClientServerAddress -Interfacealias "vEthernet (External)" -ServerAddresses ($servers)}
    "dhcp" {Set-DnsClientServerAddress -Interfacealias "vEthernet (External)" -ResetServerAddresses}
    }

$DNS = (Get-DnsClientServerAddress -Interfacealias "vEthernet (External)" -AddressFamily IPv4).ServerAddresses

Write-Host "Primary DNS Server: " $DNS[0]
Write-Host "Secondary DNS Server: " $DNS[1]