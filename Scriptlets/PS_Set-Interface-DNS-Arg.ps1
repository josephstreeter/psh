$DNSServers = "128.104.254.254","144.92.254.254"
$DNSName = "ad.doit.wisc.edu"


foreach ($ServerName in $Args){
    $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $ServerName | where{$_.IPEnabled -eq “TRUE”}

    Foreach($NIC in $NICs) {
        $NIC.SetDNSServerSearchOrder()
        $NIC.SetDNSServerSearchOrder($DNSServers)
        $NIC.SetDNSDomain($DNSName)
        }
}
