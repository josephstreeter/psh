[string]$msg = 
@"
Certain GnuPG commands will require a user to specify users (e.g., which user is the message being encrypted for). 
A user refers to anyone who owns a public/private key pair. To perform a GnuPG command that requires a certain user
as an argument, or to decrypt (or verify) a file from a certain user, the user first needs to import that user’s 
public key into your keyring.
"@

$file="$($date = get-date -uformat "%Y-%m-%d").txt"

function encrypt-message($msg)
    {
    $results = $msg | gpg --encrypt --armor --recipient "joseph.streeter76@gmail.com"
    return $results
    }

function Send-Google($pgp)
    {
    Send-MailMessage `
        -to jstreeter@madisoncollege.edu `
        -from jstreeter@madisoncollege.edu `
        -subject "Secure Message" `
        -body "Secure message attached" `
        -Attachments $file `
        -smtpserver smtp.madisoncollege.edu `
        -Port 25 #`
        #-UseSsl
    }

encrypt-message $msg | out-file .\$file
Send-Google
rm $file 


