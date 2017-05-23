Param ([string]$Forest,[string]$username)

Import-Module activedirectory

if (-not ($MyInvocation.InvocationName -eq ‘.‘)) {
     Write-Host -ForegroundColor Red “Script is not dot sourced.“
    } else {

    switch ($Forest)
        {
        'PROD' {
        if (-not (get-psdrive PROD -ea silentlycontinue)) {
        New-PSDrive `
            –Name AD `
            -Server ad.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential AD\$username) `
            -Root "//RootDSE/"
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
            -Credential (Get-Credential ADTEST\$username) `
            -Root "//RootDSE/"
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
            -Credential (Get-Credential AD\$username) `
            -Root "//RootDSE/"
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
            -Credential (Get-Credential QA\$username) `
            -Root "//RootDSE/"
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
        }
        'ITE' {
        if (-not (get-psdrive ITE -ea silentlycontinue)) {
        New-PSDrive `
            –Name DOIT `
            -Server ite.ad.wisc.edu `
            –PSProvider ActiveDirectory `
            -Credential (Get-Credential ITE\$username) `
            -Root "//RootDSE/"
            }Else{
            Write-Host -ForegroundColor Green "PSDrive already exists"
            }
        }
        Default {Write-Host "You did not enter a valid Forest Name"}
        }
    }
