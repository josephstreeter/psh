
$file="$($date = get-date -uformat "%Y-%m-%d").txt"

function encrypt-message($msg,$recipient)
    {
    if (gpg --list-key $recipient)
        {
        $results = $msg | gpg --encrypt --armor --recipient $recipient
        return $results
        }
    Else
        {
        Break
        }
    }

function Send-Message($sender,$recipient,$subject)
    {
    Send-MailMessage `
        -to $recipient `
        -from $recipient `
        -subject $subject `
        -body "Secure message attached" `
        -Attachments $file `
        -smtpserver smtp.madisoncollege.edu `
        -Port 25 #`
        #-UseSsl
    }

Clear-Host

$sender=Read-Host "Enter your email address"
$recipient=Read-Host "Enter recipient email address"
$Subject=Read-Host "Enter subject"
$msg=Read-Host "Enter Message"

encrypt-message $msg $recipient | out-file .\$file
Send-Message $sender $recipient $subject
Remove-Item $file 