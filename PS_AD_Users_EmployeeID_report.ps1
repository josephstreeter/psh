#| ? {(($_.name -match "student") -or ($_.name -match "test") -or ($_.name -match "user") -or ($_.name -match "lab") -or ($_.name -match "guest") -or ($_.name -match "video") -or ($_.name -match "librar"))}

$report = "C:\Scripts\No-emplid-report.txt"
Get-Date | Out-File $report

$OUs = @("Students;OU=Users,OU=Student,DC=MATC,DC=Madison,DC=Login","Faculty;OU=Faculty,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","Admin;OU=Admin,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","Staff;OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","Retired;OU=EmailOnly,DC=MATC,DC=Madison,DC=Login")
Foreach ($OU in $OUs)
    {
    "" | Out-File -Append $report
    $OU.split(";")[0] + " (" + $OU.Split(";")[1] + ")"  | Out-File -Append $report
    $users = (get-aduser -f '(-not(employeeid -like "*"))' -pr employeeid,department,employeetype -SearchBase $OU.Split(";")[1]) | ? {($_.employeetype -ne "none")}
    $Users.count | Out-File -Append $report
    $users  | ft name,givenname,surname,samaccountname,department -AutoSize | Out-File -Append $report
    }

Send-MailMessage `
    -to jstreeter@madisoncollege.edu `
    -from jstreeter@madisoncollege.edu `
    -Subject "No EmplID Report" `
    -Attachments $report `
    -smtp "smtp.madisoncollege.edu"

Remove-Item $report