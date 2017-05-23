Import-Module activedirectory


$Name = Read-Host "Select Forest:`   
    PRD    = matc.madison.login
    TST    = matc.ts.test `
    PRDD   = directory.madisoncollege.edu `
    TSTD   = adtest-dmz.madisoncollege.edu `n"
$Username = Read-Host "Enter administrator username"

Trap {"Error"}

switch ($Name)
    {
    'PRD' {$Forest = "matc.madison.login"}
    'TST' {$Forest = "matc.ts.test"}
    'PRDD'{$Forest = "madisoncollege.edu"}
    'TSTD'{$Forest = "adtest-dmz.madisoncollege.edu"}

    Default {Write-Host "You did not enter a valid Forest Name"}
    }


"$Name,$Username,$Forest"
if (-not (get-psdrive "$Name" -ea silentlycontinue)) 
    {
    New-PSDrive `
        –Name $Name `
        -Server "$Forest" `
        –PSProvider ActiveDirectory `
        -Credential $(Get-Credential $Username) `
        -Root "//RootDSE/" `
        -Scope Global
    }
    Else
    {
    Write-Host -ForegroundColor Green "$Forest already exists"
    }