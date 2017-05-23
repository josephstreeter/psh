CLS

$VMLoc = "C:\VM\VirtualMachines\"
$ISODir = "C:\VM\ISO\"
$ISOCentos = "CentOS-6.4-x86_64-minimal.iso"
$ISODebian = "debian-7.4.0-amd64-netinst.iso"
$ISOSuse = "openSUSE-Leap-42.1-DVD-x86_64.iso"
$ISOWS2003R2 = "WIN2K3 ENT 01.iso"
$ISOWS2008R2 = "7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso"
$ISOWS2012R2 = "SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-2_Core_MLF_X19-31419.ISO"
$ISOWIN81ENT = "9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV9.ISO"
$ISOMDT = "LiteTouchPE_x64.iso"

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
    Write-Host "    1 - Windwos Server 2003 `
    2 - Windwos Server 2008 `
    3 - Windwos Server 2012 `
    4 - Windows 8 `
    5 - Linux CentOS `
    6 - Linux Debian"

    $Global:VMOS = Read-Host "Select an OS (1 - 6)"
    if (-not($VMOS)) {
        Write-Host -ForegroundColor Red "Must provide an OS"
        Collect-VMOSInfo
        }

    Switch ($VMOS) {
        1 {$Global:VMIso = $ISODir+$ISOWS2003R2}
        2 {$Global:VMIso = $ISODir+$ISOWS2008R2}
	    3 {$Global:VMIso = $ISODir+$ISOWS2012R2}
        4 {$Global:VMIso = $ISODir+$ISOWIN81ENT}
        5 {$Global:VMIso = $ISODir+$ISOCentos}
        6 {$Global:VMIso = $ISODir+$ISODebian}
        Default {Write-Host -ForegroundColor Red "Selection must be 1 -6";Collect-VMOSInfo}
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
    if (get-item "$VMLoc$VMName\Harddrive\$VMName.vhdx" -ea SilentlyContinue) {
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
            -NewVHDPath "$VMLoc$VMName\Harddrive\$VMName.vhdx" `
            -NewVHDSizeBytes $VHDSize `
            -ea Stop
        
        Set-Vm -Name $VMName -DynamicMemory
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