# Script Name: PScheck_drive_space.ps1
# 09 JAN 2012

$os_space = 2048
$sysvol_space = 500
$ntds_space = 400
$ntds_space_gc = 600

Import-Module ActiveDirectory

$objForest = Get-ADForest
$GCs = $objForest.GlobalCatalogs
$colDomains = $objForest.Domains

foreach ($strDomain in $colDomains)
{
	$domain = Get-ADDomain $strDomain
	$colDCs = $domain.ReplicaDirectoryServers
	foreach ($dc in $colDCs)
	{
		Write-Host
		Write-Host "Checking Space on $($dc)"
		$obj_dc = Get-ADDomainController $dc
		$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $dc)
		
		# The NTDS Space Check
		$key_ntds = $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters")
		$ntds_dir = $key_ntds.GetValue("DSA Working Directory")
		$ntds_drive = $ntds_dir.Split("\")[0]
		$ntds_disk = Get-WmiObject -ComputerName $dc -Class Win32_LogicalDisk -Filter "DeviceID = '$ntds_drive'"
		$ntds_mb_space = $ntds_disk.FreeSpace / 1024 / 1024
		if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space)
		{Write-Host " NTDS Partition		OK (Disk " $ntds_drive "Free Space " $ntds_mb_space ")"}
		if (!$ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space)
		{Write-Host " NTDS Partition		Low (Disk " $ntds_drive "Free Space " $ntds_mb_space ")"}
		if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -gt $ntds_space_gc)
		{Write-Host " NTDS Partition		OK (Disk " $ntds_drive "Free Space " $ntds_mb_space ")"}
		if ($ob_dc.IsGlobalCatalog -and $ntds_mb_space -lt $ntds_space_gc)
		{Write-Host " NTDS Partition		Low (Disk " $ntds_drive "Free Space " $ntds_mb_space ")"}
		
		#The SYSVOL Space Check
		$key_sysvol = $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters")
		$sysvol_dir = $key_sysvol.GetValue("SysVol")
		$sysvol_drive = $sysvol_dir.Split("\")[0]
		$sysvol_disk = Get-WmiObject -ComputerName $dc -Class Win32_LogicalDisk -Filter "DeviceID = '$sysvol_drive'"
		$sysvol_mb_space = $sysvol_disk.FreeSpace / 1024 / 1024
		if ($sysvol_mb_space -gt $sysvol_space)
		{Write-Host " SYSVOL Partition	OK (Disk " $sysvol_drive "Free Space " $sysvol_mb_space ")"}
		if ($sysvol_mb_space -lt $sysvol_space)
		{Write-Host " SYSVOL Partition	Low (Disk " $sysvol_drive "Free Space " $sysvol_mb_space ")"}
		
		#The OS Space Check
		$key_os = $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")
		$os_dir = $key_os.GetValue("SystemRoot")
		$os_drive = $os_dir.Split("\")[0]
		$os_disk = Get-WmiObject -ComputerName $dc -Class Win32_LogicalDisk -Filter "DeviceID = '$os_drive'"
		$os_mb_space = $os_disk.FreeSpace / 1024 / 1024
		if ($os_mb_space -gt $os_space)
		{Write-Host " OS Partition		OK (Disk " $os_drive "Free Space " $os_mb_space ")"}
		if ($os_mb_space -lt $os_space)
		{Write-Host " OS Partition		Low (Disk " $os_drive "Free Space " $os_mb_space ")"}
		}
		Write-Host
	}