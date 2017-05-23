Switch ($args[0]) { 
    "home" {Set-DnsClientServerAddress -Interfacealias "vEthernet (External)" -ServerAddresses ("192.168.0.15", "192.168.0.16")}
    "dhcp" {Set-DnsClientServerAddress -Interfacealias "vEthernet (External)" -ResetServerAddresses}
    }
(Get-DnsClientServerAddress -Interfacealias "vEthernet (External)" -AddressFamily IPv4).ServerAddresses