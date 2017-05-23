$admins = @("ajdavis8,activedirectory@doit.wisc.edu")
$OrgOUOwners = "DEM-OU Owners-gs"

function connect-activedirectory {
if (-not (get-psdrive PROD -ea silentlycontinue)) {
    $ProdAdmin = Read-Host "Enter Prod CADS Admin Username"
    New-PSDrive `
        –Name PROD `
        –PSProvider ActiveDirectory `
        –Server "ad.wisc.edu" `
        –Credential (Get-Credential "$ProdAdmin") `
        –Root "//RootDSE/" `
        -Scope Global
        }

if (-not (get-psdrive QA -ea silentlycontinue)) {
        $QAAdmin = Read-Host "Enter QA CADS Admin Username"
    New-PSDrive `
        –Name QA `
        –PSProvider ActiveDirectory `
        –Server "adtest.wisc.edu" `
        –Credential (Get-Credential "$QAAdmin") `
        –Root "//RootDSE/" `
        -Scope Global
        }
}

Function Send-Message {
    $smtp = "smtp.wiscmail.wisc.edu"
    $body = "Here is your username and password for managing objects in Active Directory for your department. Please change your password as soon as possible. `
    `n `
    Production (AD.WISC.EDU) `
    Username: $AdminName `
    Password: $ProdPassword `
    `n `
    Production (ADTEST.WISC.EDU)`
    Username: $AdminName `
    Password: $QAPassword `
    `n `
    Knowledge Base `
    https://kb.wisc.edu/ams/search.php?q=active+directory&cat=0 `
    Wiki `
    https://wiki.doit.wisc.edu/confluence/display/CAD/Home"
    
    $body
    
    Send-MailMessage `
        -to $AdminEmail `
        -body $body `
        -Subject "Campus Active Directory Admin Account" `
        -SmtpServer $smtp `
        -From "Campus Active Director Service Team <activedirectory@doit.wisc.edu>"
}

connect-activedirectory


foreach ($admin in $admins) {
    $User = $admin.split(",")[0]
    $AdminEmail = $admin.split(",")[1]
    $NetID = get-aduser -f {samaccountname -eq $User} -pr *
    $AdminName = $NetID.samaccountname+"-ou"
    $AdminUPNProd = $NetID.samaccountname+"@ad.wisc.edu"
    $AdminUPNQA = $NetID.samaccountname+"@adtest.wisc.edu"
    $length = 12
    $NonAlpha = 4

    if (get-aduser -f {cn -eq $AdminName}) {
        "$AdminName already Exists"
        }
    Else {
        cd prod:
        Add-Type -Assembly System.Web
        $ProdPassword = [Web.Security.Membership]::GeneratePassword($length,$NonAlpha)
        
        New-ADUser $AdminName `
            -path "OU=users,OU=Dept Admin,OU=ENT,DC=AD,DC=wisc,DC=edu" `
            -AccountPassword  (ConvertTo-SecureString -AsPlainText $ProdPassword -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -givenname $NetID.givenname `
            -surname $NetID.sn `
            -displayname $NetID.displayname `
            -UserPrincipalName $AdminUPNProd `
            -description $orgName `
            -ea Stop
            #-OtherAttributes @{mail=$NetID.mail;telephoneNumber=$NetID.telephoneNumber}
        #Add-ADGroupMember $OrgOUOwners -member $AdminName
        
        cd QA:
        Add-Type -Assembly System.Web
        $QAPassword = [Web.Security.Membership]::GeneratePassword($length,$NonAlpha)
       
        New-ADUser $AdminName `
            -path "OU=users,OU=Dept Admin,OU=ENT,DC=ADTEST,DC=wisc,DC=edu" `
            -AccountPassword  (ConvertTo-SecureString -AsPlainText $QAPassword -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -givenname $NetID.givenname `
            -surname $NetID.sn `
            -displayname $NetID.displayname `
            -UserPrincipalName $AdminUPNQA `
            -description $orgName
            #-OtherAttributes @{mail=$NetID.mail;telephoneNumber=$NetID.telephoneNumber}
        Add-ADGroupMember $OrgOUOwners -member $AdminName
        }
    Send-Message
}