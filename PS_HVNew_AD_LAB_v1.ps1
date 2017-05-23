CLS

$VMLoc = "C:\VMs\VirtualMachines\"
$ISODir = "C:\VMs\ISO\"
$ISOWS2003R2 = "WIN2K3_STD_01.iso"
$ISOWS2008R2 = "7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso"
$ISOWS2012R2 = "9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO"

$VMHost = $(gwmi win32_computersystem).name
$VMName = "LAB-DC-"
$VMIso = $ISODir+$ISOWS2012R2
$VMMem = 512MB
$VHDSize = 40GB
$VMNet = "External"
$VMNUmber = 3


Function Create-NewVM {
    New-VM `
        -Name $VMName$i `
        -MemoryStartupBytes $VMMem `
        -ComputerName $VMHost `
        -Path $VMLoc `
        -NewVHDPath "$VMLoc$VMName$i\Harddrives\$VMName$i.vhdx" `
        -NewVHDSizeBytes $VHDSize `
        -ea Stop
}

Function Configure-VMStorage {
    $VMLogs = "$VMLoc$VMName$i\Harddrives\$VMName$i-Logs.vhdx"
    $VMDatabase = "$VMLoc$VMName$i\Harddrives\$VMName$i-DB.vhdx"

    New-VHD -Path $VMLogs -Dynamic -SizeBytes 2GB
    New-VHD -Path $VMDatabase -Dynamic -SizeBytes 2GB

    Add-VMHardDiskDrive -VMName $VMName$i -ControllerType SCSI -ControllerNumber 0 -Path $VMDatabase
    Add-VMHardDiskDrive -VMName $VMName$i -ControllerType SCSI -ControllerNumber 0 -Path $VMLogs
}

Function Configure-VMDVD {
    Set-VMDvdDrive -VMName $VMName$i -Path $VMIso -ea Stop
}

Function Configure-VMMemory {
    Set-VMMemory -VMName $VMName$i -DynamicMemoryEnable $True -MinimumBytes 512MB -MaximumBytes 1GB
}

Function Configure-VMNetwork {
    Get-VMNetworkAdapter $VMName$i -ea Stop | Connect-VMNetworkAdapter -switchname $VMNet
}

foreach ($i in (8..$VMNUmber)){
    if ($i -lt 10) {$i="0$i"}
    Create-NewVM
    Configure-VMStorage
    Configure-VMMemory
    Configure-VMDVD
    Configure-VMMemory
    Configure-VMNetwork
}