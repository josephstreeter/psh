#Import the Active Directory Module
import-module activedirectory

$duplicate_comp = @()
$comp = get-adcomputer -filter * -properties ipv4address | sort-object -property ipv4address
$sorted_ipv4 = $comp | foreach {$_.ipv4address} | sort-object
$unique_ipv4 = $comp | foreach {$_.ipv4address} | sort-object | get-unique
$duplicate_ipv4 = Compare-object -referenceobject $unique_ipv4 -differenceobject $sorted_ipv4 | foreach {$_.inputobject}

foreach ($duplicate_inst in $duplicate_ipv4)
{
    foreach ($comp_inst in $comp)
    {
        if (!($duplicate_inst.compareto($comp_inst.ipv4address)))
        {
            $duplicate_comp = $duplicate_comp + $comp_inst
        }
    }
}

$duplicate_comp | ft name,ipv4address -a 
