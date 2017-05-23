Send-MailMessage `
    -to joseph.streeter76@gmail.com `
    -from joseph.streeter76@gmail.com `
    -subject "IP Address" `
    -body $(Invoke-WebRequest http://www.joseph-streeter.com/home/getip.php).content `
    -smtpserver smtp.gmail.com -Port 587 `
    -Credential $(Get-Credential joseph.streeter76@gmail.com) `
    -UseSsl