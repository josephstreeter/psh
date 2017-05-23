$file = "C:\Scripts1\user_report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$rpt = ".\" + $rptdate + "-" + $file
$date = (Get-Date).addmonths(-12)
$dn = "ou=servers,dc=matc,dc=madison,dc=login"
$Servers = Get-ADComputer -f * -Properties name,description,LastLogonDate,operatingsystem,enabled,ipv4address,whencreated,whenchanged -SearchBase $dn 

Function Create-ServerReport
    {
    $PropArray = @()
    $Opt = New-CimSessionOption -Protocol Dcom  
    Foreach ($Server in $Servers)
        {
        if ($Session = New-CimSession -ComputerName $Server.Name -SessionOption $Opt -ea 0)
            {
            $Prop = New-Object System.Object
            $Prop | Add-Member -type NoteProperty -name Name -value $Server.name
            $Prop | Add-Member -type NoteProperty -name OperatingSystem -value $Server.operatingsystem
            $Prop | Add-Member -type NoteProperty -name LastLogonDate -value $Server.lastlogondate
            $Prop | Add-Member -type NoteProperty -name IP -value $Server.IPv4Address
            $Prop | Add-Member -type NoteProperty -name Enabled -value $Server.enabled
            $Prop | Add-Member -type NoteProperty -name whencreated -value $Server.whencreated
            $Prop | Add-Member -type NoteProperty -name whenchanged -value $Server.whenchanged
            
            $ComputerSystem =  Get-CimInstance -Class Win32_ComputerSystem –CimSession $session
            $Prop | Add-Member -type NoteProperty -name Domain -value $ComputerSystem.Domain
            $Prop | Add-Member -type NoteProperty -name Mfg -value $ComputerSystem.Manufacturer
            $Prop | Add-Member -type NoteProperty -name Model -value $ComputerSystem.Model
            $Prop | Add-Member -type NoteProperty -name Memory -value ([math]::round(($ComputerSystem.TotalPhysicalMemory / 1GB),2))

            #$SystemEnclosure = Invoke-Command -scriptblock {Get-WMIObject -class Win32_SystemEnclosure} -ComputerName $server.name -ea 0 #| Out-Null
            #$Prop | Add-Member -type NoteProperty -name SerialNumber -value $SystemEnclosure.SerialNumber
            
            $Bios = Get-CimInstance -Class Win32_BIOS –CimSession $session
            $Prop | Add-Member -type NoteProperty -name SerialNumber -value $Bios.SerialNumber
            
            $Proc = Get-CimInstance -Class Win32_Processor –CimSession $session
            $Prop | Add-Member -type NoteProperty -name ProcName -value $Proc.Name
            $Prop | Add-Member -type NoteProperty -name ProcCount -value $($Proc | measure).count
            }
        $PropArray += $Prop
        }

    $PropArray | sort name | ft * -AutoSize
    }

Function Send-ServerReport
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body "See attached report" `
        -Subject "Server Report" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -attachment $File
    Remove-Item $File
    }

Create-ServerReport | Out-File $file
Send-ServerReport