$smtp = "smtp.wiscmail.wisc.edu"
$admins = @("kbauman,jstreeter@wisc.edu","cchancellor,jstreeter@wisc.edu","kcherek,jstreeter@wisc.edu")

function connect-activedirectory {
New-PSDrive `
    –Name PROD `
    –PSProvider ActiveDirectory `
    –Server "ad.wisc.edu" `
    –Credential (Get-Credential) `
    –Root "//RootDSE/" `
    -Scope Global

New-PSDrive `
    –Name QA `
    –PSProvider ActiveDirectory `
    –Server "adtest.wisc.edu" `
    –Credential (Get-Credential) `
    –Root "//RootDSE/" `
    -Scope Global
}


foreach ($admin in $admins) {
    $username = $admin.split(",")[0]+"-ou"
    $email = $admin.split(",")[1]
    $Password = "StrongPassword"
    $body = "Here is your username and password for managing objects in Active Directory for your department. Please change your password as soon as possible. `
    `n `
    Production (AD.WISC.EDU) `
    Username: $username `
    Password: $password `
    `n `
    Production (ADTEST.WISC.EDU)`
    Username: $username `
    Password: $password `
    `n `
    Knowledge Base `
    https://kb.wisc.edu/ams/search.php?q=active+directory&cat=0 `
    Wiki `
    https://wiki.doit.wisc.edu/confluence/display/CAD/Home"
    Send-MailMessage `
        -to $email `
        -body $body `
        -Subject "Campus Active Directory Admin Account" `
        -SmtpServer $smtp `
        -From "Campus Active Director Service Team <activedirectory@doit.wisc.edu>"
    }