$strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -filter "IPEnabled = 'TRUE'"
    Foreach($strNIC in $strNICs) 
	{
	"IP Address:  " + $strNIC.IPAddress
	"DHCP Enabled: " + $strNIC.DHCPEnabled
	"DNS Domain: " + $strNIC.DNSDomain
	"DNS Servers: " + $strNIC.DNSServerSearchOrder
	"DNS Connection Suffix: " + $strNIC.DNSSuffixSearchOrder
	"DNS Register Connection Suffix: " + $strNIC.DomainDNSRegistrationEnabled
	"DNS Dynamic Register: " + $strNIC.FullDNSRegistrationEnabled
	"TCP/IP NetBIOS: " + $strNIC.TcpipNetbiosOptions
	"LMHOST Lookup Enabled: " + $strNIC.WINSEnableLMHostsLookup
        write-host ""
	}
