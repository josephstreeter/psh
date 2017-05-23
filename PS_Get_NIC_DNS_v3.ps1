$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
$searcher.filter = "(&(objectClass=user)(objectCategory=computer)(operatingSystem=*Server*))"
$objAd = $searcher.findall()

$PropArray = @()

foreach ($objComp in $objAd | select -First 20)
    {
    $Prop = New-Object System.Object
    
    $strNICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $objComp.properties.cn | where{$_.IPEnabled -eq “TRUE”}
    Foreach($strNIC in $strNICs) 
	   {
       $Prop = New-Object System.Object
       $Prop | Add-Member -type NoteProperty -name Server -value $objComp.properties.cn
       $Prop | Add-Member -type NoteProperty -name Domain -value $strNIC.DNSDomain
       $Prop | Add-Member -type NoteProperty -name DNS -value $strNIC.DNSServerSearchOrder
       $PropArray += $Prop
       }
    }
    
    
    