$SourceSha1 = "8ddcbf14eb6df11139f709320a71d197a83bf9e1"

$someFilePath = "C:\users\jstreeter\downloads\gpg4win-2.2.4.exe"
$Sha1 = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
$hashSha1 = [System.BitConverter]::ToString($sha1.ComputeHash([System.IO.File]::ReadAllBytes($someFilePath)))


$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$hashMD5 = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($someFilePath)))

$hashSha1.Replace("-","")
$SourceSha1.ToUpper()
$hashMD5.Replace("-","")

If ($hashSha1.Replace("-","") -eq $SourceSha1) {"Yes"}Else{"No"}