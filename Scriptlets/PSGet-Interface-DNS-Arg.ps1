

foreach ($strComp in $Args)
	{
    write-host $strComp
    $strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $strComp | where{$_.IPEnabled -eq “TRUE”}
    Foreach($strNIC in $strNICs) 
	{
        $strNIC.DNSDomain
        $strNIC.DNSServerSearchOrder
        write-host ""
	}
	}
