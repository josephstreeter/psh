Import-Module sqlps

$Instance = "idmdbtst01\mimstage"
$DataBase = "stagingdirectory"
$Query = @"
SELECT employeeID
FROM id_test 
WHERE employeeID = '7000097'
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $Query | ft -AutoSize

    #accountName,lastName,employeeID,employeeType,employeeStatus,immutableID