$file = "C:\Scripts1\user_report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$rpt = ".\" + $rptdate + "-" + $file
$date = (Get-Date).addmonths(-12)
$dn = "ou=servers,dc=matc,dc=madison,dc=login"
$Servers = Get-ADComputer -f * -SearchBase $dn -Properties name, description, LastLogonDate, operatingsystem, enabled, whencreated, whenchanged

Function Create-ServerReport
    {
    $PropArray = @()
    Foreach ($Server in $Servers)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name Name -value $Server.name
        $Prop | Add-Member -type NoteProperty -name OperatingSystem -value $Server.operatingsystem
        $Prop | Add-Member -type NoteProperty -name LastLogonDate -value $Server.lastlogondate
        $Prop | Add-Member -type NoteProperty -name Enabled -value $Server.enabled
        $Prop | Add-Member -type NoteProperty -name whencreated -value $Server.whencreated
        $Prop | Add-Member -type NoteProperty -name whenchanged -value $Server.whenchanged
        $PropArray += $Prop
        }

    "`nAccounts not used in over a year or never used"
    $PropArray | ? {($_.lastlogondate -lt $date)} | sort lastlogondate | ft -AutoSize
    "`nActive that are disabled"
    $PropArray | ? {$_.enabled -eq $False} | ft -AutoSize
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