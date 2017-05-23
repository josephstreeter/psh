$strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName localhost -filter "IPEnabled = 'TRUE'"
    Foreach($strNIC in $strNICs) 
	{
	If ($strNIC.DomainDNSRegistrationEnabled -eq $false) 
        {
        $strNIC.SetDynamicDNSRegistration($true,$true)
        }
    }