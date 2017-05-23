Import-Module sqlps

$Instance = "idmdbtst01\mimsync"
$DataBase = "FIMSynchronization"
$Query = @"
SELECT accountName,address,company,jobtitle,street,city,st,postalcode,employeeID,employeeType,employeeStatus,employeeNumber
FROM mms_metaverse
WHERE employeeType='S'
AND employeeStatus='D'
"@

Invoke-Sqlcmd `
    -ServerInstance $Instance `
    -Database $DataBase `
    -query $Query | ft accountName,company,jobtitle,street,city,st,postalcode,employeeID,employeeType,employeeStatus,employeeNumber

    #accountName,lastName,firstName,employeeID,employeeType,employeeStatus,employeeNumber