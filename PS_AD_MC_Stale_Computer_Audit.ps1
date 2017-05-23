$FileUsers = "C:\Scripts1\user_report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$rpt = ".\" + $rptdate + "-" + $FileUsers
$date = (Get-Date).addmonths(-12)
$dn = "ou=facstaff,dc=matc,dc=madison,dc=login"
$Computers = Get-ADComputer -f * -SearchBase $dn -Properties name, description, LastLogonDate, operatingsystem, enabled, whencreated, whenchanged

Function Create-ComputerReport
    {
    $PropArray = @()
    Foreach ($Computer in $Computers)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name Name -value $Computer.name
        $Prop | Add-Member -type NoteProperty -name OperatingSystem -value $Computer.operatingsystem
        $Prop | Add-Member -type NoteProperty -name LastLogonDate -value $Computer.lastlogondate
        $Prop | Add-Member -type NoteProperty -name Enabled -value $Computer.enabled
        $Prop | Add-Member -type NoteProperty -name whencreated -value $Computer.whencreated
        $Prop | Add-Member -type NoteProperty -name whenchanged -value $Computer.whenchanged
        $PropArray += $Prop
        }

    "`nAccounts not used in over a year or never used"
    $PropArray | ? {($_.lastlogondate -lt $date)} | sort lastlogondate | ft -AutoSize
    "`nActive that are disabled"
    $PropArray | ? {$_.enabled -eq $False} | ft -AutoSize
    }

Function Send-ComputerReport
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body "See attached report" `
        -Subject "FacStaff Computer Report" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -attachment $FileUsers
    Remove-Item $FileUsers
    }

Create-ComputerReport | Out-File $FileUsers
Send-ComputerReport
