$strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName VSNL-DENT-008 -filter "IPEnabled = 'TRUE'"
    Foreach($strNIC in $strNICs) 
	{
	"IP Address:                     " + $strNIC.IPAddress
    "IP Subnet:                      " + $strNIC.IPSubnet
    "Default Gateway:                " + $strNIC.DefaultIPGateway	
    "DHCP Enabled:                   " + $strNIC.DHCPEnabled
	"DNS Domain:                     " + $strNIC.DNSDomain
	"DNS Servers:                    " + $strNIC.DNSServerSearchOrder
	"DNS Suffix Search Order:        " + $strNIC.DNSSuffixSearchOrder
	"DNS Register Connection Suffix: " + $strNIC.DomainDNSRegistrationEnabled
	"DNS Dynamic Register:           " + $strNIC.FullDNSRegistrationEnabled
	"TCP/IP NetBIOS:                 " + $strNIC.TcpipNetbiosOptions
	"LMHOST Lookup Enabled:          " + $strNIC.WINSEnableLMHostsLookup
	"Mac Address:                    " + $strNIC.MACAddress
    write-host ""
    #$strNIC.SetDynamicDNSRegistration($true,$true)	
    }
