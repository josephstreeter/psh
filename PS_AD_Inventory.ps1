$Computers = Get-ADComputer -f {operatingsystem -like "*server*"} -pr name, lastlogondate, description, operatingsystem, operatingsystemversion | ? {$_.lastlogondate -ge (get-date).adddays(-10) -and ($_.lastlogondate -ne $NULL)}

$PropArray = @()

foreach ($computer in $computers) 
    {
    If (Test-Connection $computer.name -Count 1 -ea SilentlyContinue)
        {
        Write-Host $computer.name -ForegroundColor Green
        #Try {
        $Comp = gwmi -ComputerName $computer.name -Class win32_computersystem
        $OS   = gwmi -ComputerName $computer.name -Class win32_operatingsystem
        $bios = gwmi -ComputerName $computer.name -Class win32_bios
        $Encl = gwmi -ComputerName $computer.name -Class Win32_SystemEnclosure
        #$Tpm  = gwmi -ComputerName $computer.name -Class win32_tpm -Namespace root\cimv2\security\MicrosoftTPM
        $proc = gwmi -ComputerName $computer.name -Class win32_Processor
        $mem  = gwmi -ComputerName $computer.name -Class win32_physicalmemory
        $vol  = gwmi -ComputerName $computer.name -Class win32_volume

        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name Name -value $Comp.name
        $Prop | Add-Member -type NoteProperty -name Domain -value $Comp.domain
        $Prop | Add-Member -type NoteProperty -name Model -value $Comp.model
        $Prop | Add-Member -type NoteProperty -name OS -value $OS.caption
        $Prop | Add-Member -type NoteProperty -name SP -value $OS.CSDVersion        
        $Prop | Add-Member -type NoteProperty -name Memory -value $([Decimal]::round($Comp.TotalPhysicalMemory/1024/1024/1024))
        $Prop | Add-Member -type NoteProperty -name Role -value $Comp.Domainrole
        #DNS Domain
        #IP Address
        #Storage
        #$Prop | Add-Member -type NoteProperty -name BiosVer -value $Bios.SMBIOSBIOSVersion
        #$Prop | Add-Member -type NoteProperty -name BiosMfg -value $Bios.Manufacturer
        #$Prop | Add-Member -type NoteProperty -name BiosName -value $Bios.Name
        $Prop | Add-Member -Type NoteProperty -name HwMfg -Value $Encl.Manufacturer
        $Prop | Add-Member -Type NoteProperty -name HwModel -Value $Encl.Model
        $Prop | Add-Member -Type NoteProperty -name HwSN -Value $Encl.SerialNumber
        $Prop | Add-Member -Type NoteProperty -name HwAssetTag -Value $Encl.SMBiosAssetTag
        #$Prop | Add-Member -Type NoteProperty -name HwSecStatus -Value $Encl.SecurityStatus
        $Prop | Add-Member -Type NoteProperty -name ProcName -Value $Proc.Name.Split("@")[0]
        $Prop | Add-Member -Type NoteProperty -name ProcSpeed -Value $(If ($Proc.Name.Split("@")[1] -match "Ghz"){$Proc.Name.Split("@")[1]}) #$Proc.Speed
        $Prop | Add-Member -Type NoteProperty -name ProcCount -Value $Proc.Count
        #$Prop | Add-Member -Type NoteProperty -name TpmActive -Value $Tpm.IsActivated_InitialValue
        #$Prop | Add-Member -Type NoteProperty -name TpmEnabled -Value $Tpm.IsEnabled_InitialValue
        #$Prop | Add-Member -Type NoteProperty -name TpmOwmed -Value $Tpm.IsOwned_InitialValue
        
        $PropArray += $Prop
        #}
        #Catch {
        #Write-Host "RPC Error" -ForegroundColor Yellow
        #}        
        }
        Else
        {
        Write-Host $computer.name -ForegroundColor Red
        }
    }

$PropArray | ft * -AutoSize
$PropArray | Out-GridView
$PropArray | ConvertTo-Csv | Out-File C:\Scripts\cmdb.csv 