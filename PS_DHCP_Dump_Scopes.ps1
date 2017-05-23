$File = "C:\Scripts\scopes.txt"
Foreach ($Scope in $(netsh dhcp server 10.39.0.119 show scope <#| % {$_.split("-")[0].trim()} | ? {$_ -match 10.}#>))
    {
    $a = $Scope | ? {$_ -match 10.}
    #$a.split("-")[0].trim() + "  " + 
    $a = $a -replace "255.255\.\d{1,3}\.\d{1,3}"
    $a = $a -replace '-Active'
    $a = $a -replace '-Disabled'
    #$a = $a -replace ' .-. '
    $a | Out-File -append $File
    }
Send-MailMessage `
    -to "JDHanson1@madisoncollege.edu" `
    -From "jstreeter@madisoncollege.edu" `
    -Body "See Attached" `
    -Subject "DHCP Scopes for SMTP Relay" `
    -SmtpServer "smtp.madisoncollege.edu" `
    -Attachments $File
Remove-Item $File