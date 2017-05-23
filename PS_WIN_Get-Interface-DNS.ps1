import-module activedirectory

$Servers = get-adcomputer -f * -searchbase "ou=domain controllers,dc=ad,dc=wisc,dc=edu" 

foreach ($Server in $Servers)
   {
    $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $Server.Name | where{$_.IPEnabled -eq “TRUE”}
    Foreach($NIC in $NICs)
	{
        write-host $Server.name
        $NIC.DNSDomain
        $NIC.DNSServerSearchOrder
        write-host ""
    	}
   }


#$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
#$searcher.filter = "(&(objectClass=user)(objectCategory=computer)(operatingSystem=*Server*))"
#$objAd = $searcher.findall()

#foreach ($objComp in $objAd)
#	{
#    $strServerName = $objComp.properties.cn
#    $strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $strServerName | where{$_.IPEnabled -eq “TRUE”}
#    Foreach($strNIC in $strNICs) 
#		{
#        write-host $strServerName
#        $strNIC.DNSDomain
#        $strNIC.DNSServerSearchOrder
#        write-host ""
#    	}
#	}