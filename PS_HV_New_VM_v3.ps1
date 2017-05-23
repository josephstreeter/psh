CLS

$VMLoc = "C:\VMs\VirtualMachines\"
$ISODir = "C:\VMs\ISO\"
$ISOCentos = "CentOS-6.4-x86_64-minimal.iso"
$ISODebian = "debian-7.4.0-amd64-netinst.iso"
$ISOWS2003R2 = "WIN2K3_STD_01.iso"
$ISOWS2008R2 = "7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso"
$ISOWS2012R2 = "9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO"
$ISOWIN81ENT = "9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO"

$Global:VMHost = $(gwmi win32_computersystem).name

Function Collect-VMHostName {
    $Global:VMName = Read-Host "Enter VM name"
    if (-not($VMName)) {
        Write-Host -ForegroundColor Red "Must provide a name"
        Collect-VMHostName
        }

    if (get-vm $VMName -ea SilentlyContinue) {
        Write-Host -ForegroundColor Red "VM already exists"
        Collect-VMHostName
        }    
}

Function Collect-VMOSInfo {
    $Global:VMOS = Read-Host "Select an OS (Linux or Windows)"
    if (-not($VMOS)) {
        Write-Host -ForegroundColor Red "Must provide an OS (Linux or Windows)"
        Collect-VMOSInfo
        }

    Switch ($VMOS) {
        "Linux"  {$LinVersion = Read-Host "Select Linux Distro (Centos, or Debian)"}
        "Windows"{$WinVersion = Read-Host "Select Windows Version (2003, 2008, 2012, or Win8)"}
        Default {Write-Host -ForegroundColor Red "OS must be Linux or Windows";Collect-VMOSInfo}
        }    

    If ($VMOS -eq "Windows"){
        Switch ($WinVersion){
            "2003"{$Global:VMIso = $ISODir+$ISOWS2003R2}
            "2008"{$Global:VMIso = $ISODir+$ISOWS2008R2}
            "2012"{$Global:VMIso = $ISODir+$ISOWS2012R2}
            "Win8"{$Global:VMIso = $ISODir+$ISOWIN81ENT}
            }
        }ElseIf ($VMOS -eq "Linux"){
        Switch ($LinVersion){
            "CentOS" {$Global:VMIso = $ISODir+$ISOCentos}
            "Debian" {$Global:VMIso = $ISODir+$ISODebian}
            }
        }

    If (-Not(Test-Path $VMISO)){Write-Host -ForegroundColor Red "$VMISO Cannot be found";Collect-VMOSInfo}
}

Function Collect-VMMemory {
    $Memory = Read-Host "Enter amount of memory: 1=512MB, 2=1GB, 3=2GB[default = 512MB]"
    Switch ($Memory) {
        1 {$Global:VMMem = 512MB}
        2 {$Global:VMMem = 1GB}
        3 {$Global:VMMem = 2GB}
        Default {$Global:VMMem = 512MB}
        }
}

Function Collect-VMStorage {
    $Storage = Read-Host "Enter amount of disk space: 1=40GB, 2=60GB, 3=80GB [default = 40GB]"

    Switch ($Storage) {
        1 {$Global:VHDSize = 40GB}
        2 {$Global:VHDSize = 60GB}
        3 {$Global:VHDSize = 80GB}
        Default {$Global:VHDSize = 40GB}
        }
    if (get-item "$VMLoc$VMName\Harddrive$VMName.vhdx" -ea SilentlyContinue) {
        Write-Host -ForegroundColor Red "VHD already exists"
        Exit
        }
}

Function Collect-VMNetwork {
    $Switchs = (get-vmswitch -ComputerName $VMHost | sort switchtype)
    $Networks = @()
    $i=0
    foreach ($switch in $switchs){
        $Networks += New-object PSObject -Property @{
            "Number" = $i
            "Type" = $Switch.SwitchType
            "Name" = $Switch.Name
            "Desc" = $switch.NetAdapterInterfaceDescription
            }
        $i++
        }

    If (-not($Networks)){Write-Host -ForegroundColor Red "No Switches Exist";Exit}
    
    $Networks | select Number,Type,Name,desc | ft -AutoSize
    $a = Read-Host "Enter network"
    $Global:VMNet = $Networks[$a].name
}

Function Create-VM {
    Try {
        New-VM `
            -Name $VMName `
            -MemoryStartupBytes $VMMem `
            -ComputerName $VMHost `
            -Path $VMLoc `
            -NewVHDPath "$VMLoc$VMName\Harddrive$VMName.vhdx" `
            -NewVHDSizeBytes $VHDSize `
            -ea Stop
            }
    Catch {
        $error[0]
        Exit
        }
}

Function Connect-VMDVD {
    Try {Set-VMDvdDrive -VMName $VMName -Path $VMIso -ea Stop}
    Catch {$error[0] ; Exit}
}

Function Connect-VMNetwork {
    If ($VMOS -eq "Linux"){
        Try {
            Get-VMNetworkAdapter $VMName -ea Stop | ? {$_.islegacy -eq $false} | Remove-VMNetworkAdapter
            Add-VMNetworkAdapter -VMName $VMName -SwitchName $VMNet -IsLegacy $true -ea Stop
            }
        Catch {$error[0] ; Exit}
        }Else{
        Get-VMNetworkAdapter $VMName -ea Stop | Connect-VMNetworkAdapter -switchname $VMNet
        }
}

Collect-VMHostName
Collect-VMOSInfo
Collect-VMMemory
Collect-VMStorage
Collect-VMNetwork
Create-VM
Connect-VMDVD
Connect-VMNetwork