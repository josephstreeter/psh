$date = get-date -uformat "%Y-%m-%d"
$smtpServer = "smtp.wiscmail.wisc.edu"

$Repadmin = "c:\scripts\Repadmin-"+$date+"-Report.txt"
$DomainControlers = "c:\scripts\DCDiag-"+$date+"-Report.txt"
$DHCP = "c:\scripts\Netsh-"+$date+"-Report.txt"

Write-Host "############ Replication Summary ############" > $Repadmin
Write-Host >> $Repadmin
repadmin /replsum >> $Repadmin
Write-Host "############ Replication Pulsar ############" >> $Repadmin
Write-Host >> $Repadmin
repadmin /showrepl /repsto /verbose pulsar >> $Repadmin
Write-Host "############ Replication Info Quasar ############" >> $Repadmin
Write-Host >> $Repadmin
repadmin /showrepl /repsto /verbose quasar >> $Repadmin
Write-Host "############ Replication Magnetar ############" >> $Repadmin
Write-Host >> $Repadmin
repadmin /showrepl /repsto /verbose magnetar >> $Repadmin

Netsh dhcp show server > $DHCP

netdom /query /domain:ad.wisc.edu fsmo > $DomainControlers
nltest /server:quasar.ad.wisc.edu /domain_trusts /v >> $DomainControlers
dcdiag.exe /v /c /d /e /q /s:pulsar >> $DomainControlers

$attRepadmin = new-object Net.Mail.Attachment($Repadmin)
$attDCDiag = new-object Net.Mail.Attachment($DomainControlers)
$attNetsh = new-object Net.Mail.Attachment($DHCP)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "joseph.streeter@doit.wisc.edu"
$msg.To.Add("joseph.streeter@doit.wisc.edu")
$msg.Subject = "Active Directory Health Report "+$date
$msg.Body = "Attached is the Active Directory Health Report"
$msg.Attachments.Add($attRepadmin)
$msg.Attachments.Add($attDCDiag)
$msg.Attachments.Add($attNetsh)
$smtp.Send($msg)
$att.Dispose()