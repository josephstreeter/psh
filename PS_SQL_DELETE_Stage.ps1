Import-Module sqlps

$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"
$Type="I"
$accountName="jstreeter"
$lastName="Streeter"
$firstName="Joseph"
$employeeID="123456"
$employeeType="E"
$employeeStatus="A"
$immutableID="GUID"

$Query = @"
DELETE FROM identities
 WHERE employeeID = '$employeeID'
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $Query | ft -AutoSize