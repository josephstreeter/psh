Import-Module sqlps

$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"
$Type="I"
$accountName="jstreeter"

$Query = @"
UPDATE identities
 SET employeeType='$TYpe'
 WHERE accountName='$accountName';
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $Query | ft -AutoSize
    
 