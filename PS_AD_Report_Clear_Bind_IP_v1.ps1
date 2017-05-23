Write-Host -ForegroundColor Yellow "Loading Modules `n"
Import-Module activedirectory

Write-Host -ForegroundColor Yellow "Set Date `n"
$date = get-date -uformat "%Y-%m-%d"
"$Date`n"

Write-Host -ForegroundColor Yellow "Set Domain `n"
$Domain = (get-addomain).Forest.toupper()
$AD_Env = (get-addomain).Name
# $DSA = $(get-adcomputer -f * -searchbase "ou=domain controllers,$(Get-ADDomain)").name ##PS Version 3.0 only##
$DSA = foreach ($computer in $(get-adcomputer -f * -searchbase "ou=domain controllers,$(get-addomain)")) {$computer.name}
"$Domain`n"

Try {
	$computers=Get-EventLog -LogName "Directory Service" -ComputerName $DSA -After $((get-date).addhours(-24)) | `
	 ? {$_.eventID -eq 2889} | % {$_.replacementstrings[1].replace("AD\","").replace("$","")} | group | select name
	}
Catch {
	"Failed to collect log info - " + $Error
	Break
	}
	
Try {
	$list=foreach ($computer in $computers) {$a=$computer.name;Get-ADObject -Filter {name -eq $a} -pr ObjectCategory, OperatingSystem, OperatingSystemVersion | `
	select Name, ObjectClass, OperatingSystem, OperatingSystemVersion}
	#$list | sort objectclass, Name | ft -auto 
	}
Catch {
	"Failed to enumerate objects - " + $Error
	Break
	}


$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "activedirectory@doit.wisc.edu"
$mailto = "activedirectory@doit.wisc.edu"

$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = $mailFrom
$msg.To.Add($mailTo)
$msg.Subject = "Clear Binds - $date ($domain)"
$msg.Body = $list | sort objectclass, Name | ft -auto | Out-String

$smtp.Send($msg)

#Get-EventLog -LogName "Directory Service" -ComputerName Pulsar, Magnetar, Quasar -After $((get-date).adddays(-1)) | ? {$_.eventID -eq 2889} | % {$_.replacementstrings[1].replace("$","")}
#Get-EventLog -LogName "Directory Service" -ComputerName Pulsar, Magnetar, Quasar -After $((get-date).adddays(-1)) | ? {$_.eventID -eq 2889} | % {$_.replacementstrings[0].split(":")[1]}