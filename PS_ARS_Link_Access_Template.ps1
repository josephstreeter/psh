Connect-QADService -service 'localhost' -proxy

New-QARSAccessTemplateLink `
    -AccessTemplate 'Configuration/Access Templates/CADS/CADS-AT-OU-OWNERS' `
    -Trustee 'ADTEST\CADS-GS-DEPT-OU-OWNERS' `
    -DirectoryObject 'OU=DEPT,OU=orgUnits,DC=adtest,DC=wisc,DC=edu'
