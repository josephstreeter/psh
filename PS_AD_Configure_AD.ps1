

Function Configure-DNS {
Set-DnsServerScavenging `
    -ComputerName $DC `
    -ScavengingInterval 3.00:00:00 `
    -NoRefreshInterval 3.00:00:00 `
    -RefreshInterval 3.00:00:00 `
    -ApplyOnAllZones `
    -passthru

Set-DnsServerForwarder `
    -ComputerName $DC `
    -IPAddress 128.104.254.254,144.92.254.254 `
    -passthru

Set-DnsServerRecursion `
    -ComputerName $DC `
    -Enable $False `
    -Passthru

Get-DnsServerZone -ComputerName $DC | ? {$_.IsAutoCreated -eq $False} | Set-DnsServerZoneAging `
    -ComputerName $DC `
    -Aging $true `
    -NoRefreshInterval 3.00:00:00 `
    -RefreshInterval 3.00:00:00 `
    -PassThru 
}

Function Configure-DsHeuristics {
Set-ADObject `
    "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$((Get-ADDomain).distinguishedName)" `
    -add @{dsHeuristics='00100000'} `
    -PassThru
}

Function Configure-StaticPorts {
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$DC)

    $Key = $Reg.CreateSubKey("SYSTEM\CurrentControlSet\Services\NTDS").CreateSubKey("Parameters")
    $Key.SetValue("TCP/IP Port","5200")

    $Key = $Reg.CreateSubKey("SYSTEM\CurrentControlSet\Services\Netlogon").CreateSubKey("Parameters")
    $Key.SetValue("DCTCPIPPort","5200")

    $Key = $Reg.CreateSubKey("SYSTEM\CurrentControlSet\Services\NTFRS").CreateSubKey("Parameters")
    $Key.SetValue("RPC TCP/IP Port Assignment","5100")
    }


Foreach ($DC in $(Get-ADDomaincontroller -filter *).Hostname){
    Configure-DNS
    Configure-StaticPorts    
    }

Configure-DsHeuristics