$VMNames = @("DC-A-01","DC-B-01","AS-B-01")
$VHDSize = 60GB
$VMMemory = 1024MB
$VMIso = "C:\Scripts\ISO\en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_vl_build_x64_dvd_617403.iso"

foreach ($VMName in $VMNames) {
    New-VM `
        -Name $VMName `
        -MemoryStartupBytes $VMMemory `
        -ComputerName $(gwmi win32_computersystem).name `
        -Path "C:\Users\Public\Documents\Hyper-V" `
        -NewVHDPath "C:\Users\Public\Documents\Hyper-V\$VMName\$VMName.vhdx" `
        -NewVHDSizeBytes $VHDSize 
    
    Set-VMDvdDrive -VMName $VMName -Path $VMIso
    }