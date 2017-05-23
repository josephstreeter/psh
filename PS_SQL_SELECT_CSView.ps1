Import-Module sqlps

$Instance = "CSDB02"
$DataBase = "CSTST"
$Query = @"
SELECT *
FROM PS_Z_ID_MGT_STU2_VW
WHERE LAST_NAME = 'streeter' 
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $Query `
    -Username "svc-csma-ts" `
    -Password "MadisonCollege2015_!"