<#
.SYNOPSIS
A set of functions for using GNUpg to encrypt and decrypt files

See further documentation at: TBD

Author: Joseph Streeter

.DESCRIPTION
See:
Get-Help Decrypt-Files
Get-Help Encrypt-Files
Get-Help Set-PassPhrase
Get-Help Retrieve-PassPhrase
Get-Help Set-Recipient
#>

<#
.SYNOPSIS
Decrypts PGP encrypted files

.DESCRIPTION
Uses the passphrase provided through the Set-PassPhrase function to decrypt
the file. This function assumes that ASCII Armoring was used. 
#>
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

<#
.SYNOPSIS
Decrypts PGP encrypted files

.DESCRIPTION
Encrypts all files located in the directory specified by $Dir. The recipent 
is provided through the Set-Recipient function.
This function assumes that ASCII Armoring is to be used. 
#>
function Encrypt-Files()
    {
    $files = List-Files "*"
    if (-not($recipient)){Set-Recipient}
    foreach ($file in $files)
        {
        gpg -r $recipient --armor --batch -e $($file.fullname)
        }
    }
<#
.SYNOPSIS
Lists all files located in the directory specified by $Dir

.DESCRIPTION
Lists all files located in the directory specified by $Dir. The files returned
can be filtered by specifying a file extension. 

.PARAMETER Ext
Optional. The file extensions to display.
#>
function List-Files()
	{
    Param([string]$ext="*")
    if (-not($dir)){Set-Directory}
	$Results = Get-Childitem $dir | ? {$_.name -like "*.$ext"}
	Return $Results
	}
<#
.SYNOPSIS
Lists all archieved files located in the directory specified by $Dir/archive

.DESCRIPTION
Lists all files located in the directory specified by $Dir/archive. The files returned
can be filtered by specifying a file extension. 

.PARAMETER Ext
Optional. The file extensions to display. Defaults to all files
#>
function List-Archive()
    {
    Param([string]$ext="*")
    if (-not($dir)){Set-Directory}
    $Results = Get-Childitem $dir/archive | ? {$_.name -like "*.$ext"}
    Return $Results
    }
<#
.SYNOPSIS
Deletes all files located in the directory specified by $Dir

.DESCRIPTION
Deletes all files located in the directory specified by $Dir. The files returned
can be filtered by specifying a file extension. 

.PARAMETER Ext
Optional. The file extensions to delete.
#>
function Delete-Files()
    {
    Param([string]$ext="*")
    if (-not($dir)){Set-Directory}
	Remove-Item -path $dir/*.$ext
    }
<#
.SYNOPSIS
Archives all files located in the directory specified by $Dir

.DESCRIPTION
Archives all files located in the directory specified by $Dir. The files returned
can be filtered by specifying a file extension. 

.PARAMETER Ext
Optional. The file extensions to delete. Defaults to all files
#>
function Archive-Files()
    {
	Param([string]$ext="*")
    if (-not($dir)){Set-Directory}
    if (-not(get-Item $dir\archive)){write-host "error";break}
	Move-Item -path $dir/*.$ext -destination $dir\archive\
    }
<#
.SYNOPSIS
Restores archived files to the directory specified by $Dir

.DESCRIPTION
Restores archived files to the directory specified by $Dir. The files restored
can be filtered by specifying a file extension. 

.PARAMETER Ext
Optional. The file extensions to restore. Defaults to all files.
#>
function Restore-Files()
    {
    Param([string]$ext="*")
    if (-not($dir)){Set-Directory}
    if (-not(get-Item $dir\archive)){write-host "error";break}
    Move-Item -path $dir/archive/*.$ext -destination $dir
    }
<#
.SYNOPSIS
Collects the PGP user's passphrase for use in decrypting files

.DESCRIPTION
Collects the PGP user's passphrase for use in decrypting files. The 
passphrase is stored as a secure string. While not the ideal level
of security, it at least isn't stored in plain text. 
#>
function Set-PassPhrase()
	{
    $Global:SecurePassword = Read-Host -Prompt "Enter PGP Passphrase" -AsSecureString	
	}
<#
.SYNOPSIS
Retrieves the PGP user's passphrase for use in decrypting files

.DESCRIPTION
Retrieves the PGP user's passphrase for use in decrypting files. The 
passphrase is stored as a secure string. While not the ideal level
of security, it at least isn't stored in plain text. 
#>
function Retrieve-Passphrase()
    {
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    Return $Password
    }
<#
.SYNOPSIS
Collects the intended recipient of the PGP encrypted file.

.DESCRIPTION
Collects the intended recipient of the PGP encrypted file. The 
recipient's email address is compared to public keys installed
in the keystore and errors if a corresponding key doesn't 
exist.
#>
function Set-Recipient()
	{
	[string]$Global:recipient=Read-Host "Enter PGP Recipient"
	if (-not(gpg --list-keys | select-string $recipient)){"No public key found for the recipent entered"}
    }

<#
.SYNOPSIS
Sets the directory in which the files to be encrypted or
decrypted can be found.

.DESCRIPTION
Sets the directory in which the files to be encrypted or
decrypted can be found. Populates the $Dir variable. 
#>
function Set-Directory()
    {
    Param([Parameter(Mandatory=$true)][string]$directory)
    $Global:dir=$directory
    }