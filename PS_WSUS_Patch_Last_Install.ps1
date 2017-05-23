$file = "C:\Scripts1\patch_install_report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$rpt = ".\" + $rptdate + "-" + $file
$date = (Get-Date).addmonths(-12)
$dn = "ou=servers,dc=matc,dc=madison,dc=login"
$Servers = Get-ADComputer -f {OperatingSystem -like "Windows*"} -Properties name,LastLogonDate,operatingsystem,ipv4address -SearchBase $dn | sort name

    $PropArray = @()
    $Opt = New-CimSessionOption -Protocol Dcom  
    Foreach ($Server in $Servers)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name Name -value $Server.name
        $Prop | Add-Member -type NoteProperty -name OperatingSystem -value $Server.operatingsystem
        $Prop | Add-Member -type NoteProperty -name IP -value $Server.IPv4Address
        $Prop | Add-Member -type NoteProperty -name LastLogon -value $Server.LastLogonDate
        if ($Session = New-CimSession -ComputerName $Server.Name -SessionOption $Opt -ea 0)
            {
            $ComputerSystem =  $(Get-CimInstance -Class Win32_QuickFixEngineering –CimSession $session )
            $patchDate = $ComputerSystem | sort -Descending InstalledOn | select -first 1
            $Prop | Add-Member -type NoteProperty -name LastPatched -value $patchDate.installedon
            $Prop | Add-Member -type NoteProperty -name Patchedby -value $patchDate.installedby
            }
            Else
            {
            $Prop | Add-Member -type NoteProperty -name LastPatched -value "Unavailable"
            $Prop | Add-Member -type NoteProperty -name Patchedby -value "Unavailable"
            }   
        $Prop | ft * -AutoSize
        $PropArray += $Prop
        }
    
    "`nWindows Server 2003 Hosts" | Out-File $file
    $PropArray | % {If ($_.operatingSystem -match "2003") {$_}} | ft -AutoSize | Out-File $file -Append
    "`nWindows Server 2008 Hosts" | Out-File $file -Append
    $PropArray | % {If ($_.operatingSystem -match "2008") {$_}} | ft -AutoSize | Out-File $file -Append
    "`nWindows Server 2012 Hosts" | Out-File $file -Append
    $PropArray | % {If ($_.operatingSystem -match "2012") {$_}} | ft -AutoSize | Out-File $file -Append
    "`nServers not patched in last 30 Days" | Out-File $file -Append
    $PropArray | % {If (($_.LastPatched -lt $(get-date).adddays(-30)) -and ($_.LastPatched -gt $(get-date).adddays(-60))) {$_}} | sort -Descending LastPatched | ft -AutoSize | Out-File $file -Append
    "`nServers not patched in last 60 Days" | Out-File $file -Append
    $PropArray | % {If (($_.LastPatched -lt $(get-date).adddays(-60)) -and ($_.LastPatched -gt $(get-date).adddays(-90))) {$_}} | sort -Descending LastPatched | ft -AutoSize | Out-File $file -Append
    "`nServers not patched in last 90+ Days" | Out-File $file -Append
    $PropArray | % {If ($_.LastPatched -lt $(get-date).adddays(-90)) {$_}} | sort -Descending LastPatched | ft -AutoSize | Out-File $file -Append
    "`nAll Servers" | Out-File $file -Append
    $PropArray | sort name | ft * -AutoSize | Out-File $file -Append

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

#Create-ServerReport | Out-File $file
#Send-ServerReport