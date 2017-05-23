New-PSDrive `
    –Name Test `
    -Server "matc.ts.test" `
    –PSProvider ActiveDirectory `
    -Credential $(Get-Credential jstreeter_a@matc.ts.test) `
    -Root "//RootDSE/" `
    -Scope Global

#(get-aduser -f '-not (employeeid -like "*")' -pr employeeid -SearchBase "OU=Users,OU=Student,DC=MATC,DC=Madison,DC=TS,DC=Test").count