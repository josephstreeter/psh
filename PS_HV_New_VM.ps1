Param (
    [string]$Name,
    [string]$Computer,
    [string]$OS,
    [int32]$Memory,
    [int64]$Storage,
    [string]$Network
    )

$VMIso = "C:\VMs\ISO\CentOS-6.4-x86_64-minimal.iso"

if (-not($OS)) {
    Write-Host -ForegroundColor Red "Must provide a name"
    Exit
    }Else{
    $VMName = $Name
    }

if (-not($OS)) {
    Write-Host -ForegroundColor Red "Must provide an OS (Linux or Windows)"
    Exit
    }ElseIf ($OS -eq "Linux") {
    $VMIso = "C:\VMs\ISO\CentOS-6.4-x86_64-minimal.iso"
    }Elseif ($OS -eq "Windows") {
    $VMIso = "C:\Scripts\ISO\en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_vl_build_x64_dvd_617403.iso"
    #$VMIso = "C:\VMs\ISO\9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.iso"
    }Else{
    Write-Host -ForegroundColor Red "OS must be Linux or Windows"
    Exit
    }

if (!($Computer)) {
    $VMHost = $(gwmi win32_computersystem).name
    }Else{
    $VMHost = $Computer
    }

if (!($Storage)) {
    $VHDSize = 40GB
    }Else{
    $VHDSize = $Storage
    }

If (!($Memory)) {
    $VMMemory = 512MB
    }Else{
    $VMMemory = $Memory
    }

If (!($Network)) {
    [string]$VMSwitch = "External"
    }Else{
    $VMSwitch = $Network
    }

if (!(Get-VMSwitch $VMSwitch -ea SilentlyContinue)) {
    Write-Host -ForegroundColor Red "$VMSwitch doesn't exist"
    Exit
    }

 if (!(get-item $VMIso -ea SilentlyContinue)) {
    Write-Host -ForegroundColor Red "$VMIso doesn't exists"
    Exit
    }

 if (get-vm $VMName -ea SilentlyContinue) {
    Write-Host -ForegroundColor Red "VM already exists"
    Exit
    }

 if (get-item "C:\Users\Public\Documents\Hyper-V\$VMName\Harddrive$VMName.vhdx" -ea SilentlyContinue) {
    Write-Host -ForegroundColor Red "VHD already exists"
    Exit
    }

Try {
    New-VM `
        -Name $VMName `
        -MemoryStartupBytes $VMMemory `
        -ComputerName $VMHost `
        -Path "C:\Users\Public\Documents\Hyper-V" `
        -NewVHDPath "C:\Users\Public\Documents\Hyper-V\$VMName\Harddrive$VMName.vhdx" `
        -NewVHDSizeBytes $VHDSize `
        -ea Stop
        }
Catch {
    $error[0]
    Exit
    }

Try {
    Set-VMDvdDrive -VMName $VMName -Path $VMIso -ea Stop
    }
Catch {
    $error[0]
    Exit
    }

If ($OS -eq "Linux"){
    Try {
        Get-VMNetworkAdapter $VMName -ea Stop | ? {$_.islegacy -eq $false} | Remove-VMNetworkAdapter
        Add-VMNetworkAdapter -VMName $VMName -SwitchName $VMSwitch -IsLegacy $true -ea Stop
        }
    Catch {
        $error[0]
        Exit
        }
}Else{
    Get-VMNetworkAdapter $VMName -ea Stop | Connect-VMNetworkAdapter -switchname $VMSwitch
    }