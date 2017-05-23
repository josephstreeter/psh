function List-Files()
	{
    Param([string]$ext="*")
	$Results = Get-Childitem $dir | ? {$_.name -like "*.$ext"}
	Return $Results
	}

function List-Archive()
    {
    Param([string]$ext="*")
    $Results = Get-Childitem $dir/archive | ? {$_.name -like "*.$ext"}
    Return $Results
    }

function Decrypt-Files()
	{
	$files = list-Files "asc"
	if (-not($SecurePassword)){Set-Passphrase}
	$pass=retrieve-passphrase
    foreach ($file in $files)
		{
        try {gpg -o $($file.fullname).replace(".asc","") --passphrase $pass --batch -d $($file.fullname)}
        catch {"Failed"}
		}
	}

function Encrypt-Files()
    {
    $files = List-Files "*"
    if (-not($recipient)){Set-Recipient}
    foreach ($file in $files)
        {
        gpg -r $recipient --armor --batch -e $($file.fullname)
        }
    }

function Delete-Files()
    {
    Param([Parameter(Mandatory=$True)][string]$ext)
	Remove-Item -path $dir/*.$ext
    }

function Archive-Files()
    {
	Param([Parameter(Mandatory=$True)][string]$ext)
    if (-not(get-Item $dir\archive)){write-host "error";break}
	Move-Item -path $dir/*.$ext -destination $dir\archive\
    }

function Restore-Files()
    {
    Param([Parameter(Mandatory=$True)][string]$ext)
    if (-not(get-Item $dir\archive)){write-host "error";break}
    Move-Item -path $dir/archive/*.$ext -destination $dir
    }

function Delete-Files()
    {
    Param([Parameter(Mandatory=$True)][string]$ext)
    Remove-Item -path $dir/*.$ext
    }

function set-passphrase()
	{
    $Global:SecurePassword = Read-Host -Prompt "Enter PGP Passphrase" -AsSecureString	
	}

function retrieve-passphrase()
    {
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    Return $Password
    }

function set-recipient()
	{
	[string]$Global:recipient=Read-Host "Enter PGP Recipient"
	if (-not(gpg --list-keys | select-string $recipient)){"No public key found for the recipent entered"}
    }

$dir="C:\scripts\mydrive"

#Get-EncryptedFiles
#Get-UnencryptedFiles
#Decrypt-Files $files
#Encrypt-Files $files
#Delete-Files
#Archive-Files
#$pass=set-passphrase
