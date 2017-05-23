$VMNames = @("SRV-A-01", "SRV-B-02", "RT-ISP-01")
$VHDSize = 40GB
$VMMemory = 512MB
$VMIso = "C:\Scripts\ISO\CentOS-6.4-x86_64-minimal.iso"

foreach ($VMName in $VMNames) {
    New-VM `
        -Name $VMName `
        -MemoryStartupBytes $VMMemory `
        -ComputerName $(gwmi win32_computersystem).name `
        -Path "C:\Users\Public\Documents\Hyper-V" `
        -NewVHDPath "C:\Users\Public\Documents\Hyper-V\$VMName\$VMName.vhdx" `
        -NewVHDSizeBytes $VHDSize 
    
    Set-VMDvdDrive -VMName $VMName -Path $VMIso
    
    Get-VMNetworkAdapter $VMName | ? {$_.islegacy -eq $false} | Remove-VMNetworkAdapter
    
    if ($VMName -like "RT-*") {
        Add-VMNetworkAdapter -VMName $VMName -SwitchName "External" -IsLegacy $true
        Add-VMNetworkAdapter -VMName $VMName -SwitchName "Network A" -IsLegacy $true
        Add-VMNetworkAdapter -VMName $VMName -SwitchName "Network B" -IsLegacy $true
        } Elseif ($VMName -like "*-A-*"){
        Add-VMNetworkAdapter -VMName $VMName -SwitchName "Network A" -IsLegacy $true
        } Elseif ($VMName -like "*-B-*"){
        Add-VMNetworkAdapter -VMName $VMName -SwitchName "Network B" -IsLegacy $true 
       }
    Start-VM $VMName
    }