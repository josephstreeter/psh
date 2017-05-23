import-module activedirectory

$date = get-date -uformat "%Y-%m-%d"
$Domain = (Get-ADDomain).dnsroot.toUpper()
$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "joseph.streeter@doit.wisc.edu"
$mailto = "joseph.streeter@doit.wisc.edu"

If ($changes = Get-WinEvent -computername magnetar.ad.wisc.edu -FilterHashtable @{Logname='security';id='5136';StartTime=$((Get-Date).addhours(-1))} -ea silentlycontinue) 
	{
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	$msg.From = $mailFrom
	$msg.To.Add($mailTo)
	$msg.Subject = "A Sensitive Object Has Been Modified "+$date+" ("+$Domain+")"
	$msg.Body = $($changes | fl)|Out-String

	$smtp.Send($msg)
	}