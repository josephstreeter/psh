$ipaddress = "192.168.0.225" 
$ipprefix = "24" 
$ipgw = "192.168.0.1" 
$ipdns = "192.168.0.225" 
$ipif = (Get-NetAdapter).ifIndex 
$newname = "DC-MAD-02" 

New-NetIPAddress `
    -IPAddress $ipaddress `
    -PrefixLength $ipprefix ` 
    -InterfaceIndex $ipif `
    -DefaultGateway $ipgw 

Function Install-RSAT {
    Add-WindowsFeature "RSAT-AD-Tools" 
}

Function Rename-Host {
    Rename-Computer -NewName $newname -force 
    Restart-Computer
}