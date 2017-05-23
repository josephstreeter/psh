$file = "C:\Scripts1\Service_Account_report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$rpt = ".\" + $rptdate + "-" + $file
$date = (Get-Date).addmonths(-12)
$dn = "ou=ServiceAcct,dc=matc,dc=madison,dc=login"
$Users = Get-ADUser -f * -SearchBase $dn -Properties employeeID, sn, givenname, name, LastLogonDate, enabled, mail, whencreated, whenchanged

Function Create-UserReport
    {
    $PropArray = @()
    Foreach ($User in $Users)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name name -value $User.name
        $Prop | Add-Member -type NoteProperty -name employeeID -value $User.employeeID
        $Prop | Add-Member -type NoteProperty -name LastLogonDate -value $User.lastlogondate
        $Prop | Add-Member -type NoteProperty -name Enabled -value $User.enabled
        $Prop | Add-Member -type NoteProperty -name Mail -value $User.mail
        $Prop | Add-Member -type NoteProperty -name whencreated -value $User.whencreated
        $Prop | Add-Member -type NoteProperty -name whenchanged -value $User.whenchanged
        $PropArray += $Prop
        }

    "`nEnabled accounts not used in over a year or never used"
    $PropArray | ? {($_.lastlogondate -lt $date) -and ($_.enabled -eq $true)} | sort lastlogondate | ft -AutoSize
    "`nDisabled accounts"
    $PropArray | ? {$_.enabled -eq $False} | ft -AutoSize
    }

Function Send-UserReport
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body "See attached report" `
        -Subject "Stale Service Account Report" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -attachment $File
    Remove-Item $File
    }

Create-UserReport | Out-File $file
Send-UserReport