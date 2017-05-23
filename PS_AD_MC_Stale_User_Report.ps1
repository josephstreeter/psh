$file = "User_Report.txt"
$rptdate = (get-date).ToShortDateString().Replace("/","-")
$date = (Get-Date).addmonths(-12)
$OUs = @(
    "Staff;OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Faculty;OU=Faculty,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Tech Services;OU=TechServices,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Administration;OU=Admin,OU=FacStaff,DC=MATC,DC=Madison,DC=login",
    "Contingent;OU=NonEmployee,DC=MATC,DC=Madison,DC=login"#,
    "Retiree;OU=EmailOnly,DC=MATC,DC=Madison,DC=login"
    )

#######################################################################################################

Function Query-AD($OU)
    {
    $Results = Get-ADUser -f * -SearchBase $($OU.split(";")[1]) -Properties employeeID, sn, givenname, name, LastLogonDate, enabled, mail, whencreated, whenchanged
    Return $Results
    }

Function Create-UserReport($Users,$OU)
    {
    $PropArray = @()
    Foreach ($User in $Users)
        {
        $Prop = New-Object -TypeName PSObject -Property @{
                                                        "sAMAccountName"=$User.sAMAccountName
                                                        "name"=$User.name
                                                        "employeeID"=$User.employeeID
                                                        "LastLogonDate"=$User.lastlogondate
                                                        "Enabled"=$User.enabled
                                                        "Mail"=$User.mail
                                                        "whencreated"=$User.whencreated
                                                        "whenchanged"=$User.whenchanged
                                                        }
        $PropArray += $Prop
        }

    "`nAccounts not used in over a year or never used"
    $PropArray | ? {($_.lastlogondate -lt $date) -and ($_.enabled -eq $true)} | sort lastlogondate | ft sAMAccountName,name,employeeID,Mail,Enabled,LastLogonDate,whencreated -AutoSize
    "`nActive that are disabled"
    $PropArray | ? {$_.enabled -eq $False} | ft sAMAccountName,name,employeeID,Mail,Enabled,LastLogonDate,whencreated -AutoSize
    }

Function Send-UserReport
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body "Stale user reports attached." `
        -Subject "Stale User Report" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -attachment $(ls *user_report.txt)
    $(ls *user_report.txt) | Remove-Item 
    }

#######################################################################################################

Foreach ($OU in $OUs)
    {
    $Users=Query-AD $OU
    Create-UserReport $Users $($OU.Split(";")[0]) | Out-File $rptdate_$($OU.Split(";")[0])_$file -Width 1000
    }
Send-UserReport