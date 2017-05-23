
$Forest = Read-Host "Enter Forest`n PROD = ad.wisc.edu `n QA = qa.ad.wisc.edu `n ADTEST = adtest.wisc.edu `n ITE = ite.ad.wisc.edu `n DS = ds.wisc.edu `n DOIT = ad.doit.wisc.edu `n"

$Username = Read-Host "Enter administrator username"

Trap {"Error"}

Import-Module activedirectory

switch ($Forest)
    {
    'PROD' {
    if (-not (get-psdrive PROD -ea silentlycontinue)) {
        New-PSDrive `
            –Name PROD `
            -Server ad.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global 
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
    }
    'ADTEST' {
    if (-not (get-psdrive ADTEST -ea silentlycontinue)) {
        New-PSDrive `
            –Name ADTEST `
            -Server adtest.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
    }
    'DOIT' {
    if (-not (get-psdrive DOIT -ea silentlycontinue)) {
        New-PSDrive `
            –Name DOIT `
            -Server ad.doit.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
    }
    'QA' {
    if (-not (get-psdrive QA -ea silentlycontinue)) {
        New-PSDrive `
            –Name QA `
            -Server qa.ad.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
    }
    'ITE' {
    if (-not (get-psdrive ITE -ea silentlycontinue)) {
        New-PSDrive `
            –Name ITE `
            -Server ite.ad.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
        }
    'DS' {
    if (-not (get-psdrive DS -ea silentlycontinue)) {
        New-PSDrive `
            –Name DS `
            -Server ds.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential $username) `
            -Root "//RootDSE/" `
            -Scope Global
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
        }
    Default {Write-Host "You did not enter a valid Forest Name"}
        }
