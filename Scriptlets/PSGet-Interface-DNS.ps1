$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
$searcher.filter = "(&(objectClass=user)(objectCategory=computer)(operatingSystem=*Server*))"
$objAd = $searcher.findall()

foreach ($objComp in $objAd)
    {
    $strServerName = $objComp.properties.cn
    write-host $strServerName
    $strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $strServerName | where{$_.IPEnabled -eq “TRUE”}
    Foreach($strNIC in $strNICs) 
	{
        $strNIC.DNSDomain
        $strNIC.DNSServerSearchOrder
        write-host ""
    	}
    }
