$DomainName = "columbia.wi.us"
$NetBiosName = "COLUMBIA"
$DatabasePath = "D:\NTDS"
$LogPath = "L:\Logs"
$SysvolPath = "D:\SYSVOL"

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


Function New-Forest ($DomainName,$NetBiosName,$DatabasePath,$LogPath,$SysvolPath){
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainMode "Win2012R2" `
    -ForestMode "Win2012R2" `
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

New-Forest($DomainName,$NetBiosName,$DatabasePath,$LogPath,$SysvolPath)