$DomainName = "columbia.wi.us"
$NetBiosName = "COLUMBIA"
$DatabasePath = "D:\NTDS"
$LogPath = "L:\Logs"
$SysvolPath = "D:\SYSVOL"
$SafeModeAdmin = "Pa$$Word123456" | ConvertTo-SecureString -AsPlainText -Force

Function Create-DatabasePath($DatabasePath) {
If (-not(get-item $DataBasePath.split("\")[0] -ea silentlycontinue)) {
	$DataBasePath.split("\")[0] + " drive doesn't exist"
	Exit
	} Else {
	If (-not(get-item $DataBasePath -ea silentlycontinue)) {
		New-Item $DataBasePath -type Directory
	}
	}
}

Function Create-SysvolPath($SysvolPath) {
If (-not(get-item $SysVolPath.split("\")[0] -ea silentlycontinue)) {
	$SysVolPath.split("\")[0] + " drive doesn't exist"
	Exit
	} Else {
	If (-not(get-item $SysvolPath -ea silentlycontinue)) {
		New-Item $SysvolPath -type Directory
	}
	}
}

Function Create-LogPath($LogPath) {
If (-not(get-item $LogPath.split("\")[0] -ea silentlycontinue)) {
	$LogPath.split("\")[0] + " drive doesn't exist"
	#Exit
	} Else {
	If (-not(get-item $LogPath -ea silentlycontinue)) {
		New-Item $LogPath -type Directory
	}
	}
}

Function Install-ADDSRoles {
Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name "DNS" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools
}

Function New-Forest {
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainMode "Win2012R2" `
    -ForestMode "Win2012R2" `
    -SafeModeAdministratorPassword $SafeModeAdmin `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -CreateDnsDelegation:$false `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBiosName `
    -DatabasePath $DatabasePath `
    -LogPath $LogPath `
    -SysvolPath $SysvolPath `
    -Force:$true
}

Create-DatabasePath($DatabasePath)
Create-SysvolPath($SysvolPath)
Create-LogPath($LogPath)
Install-ADDSRoles
New-Forest