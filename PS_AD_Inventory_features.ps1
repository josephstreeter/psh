

Function Get-Roles($DC) 
    {
    Invoke-Command -ComputerName $DC.hostname -UseSSL -ScriptBlock {
        import-module servermanager -ErrorAction Stop | out-null
        Get-WindowsFeature -ErrorAction SilentlyContinue | ? {($_.installed -eq "True") -and ($_.featuretype -eq "Role")}
        }
    }

$DCs =  Get-ADDomainController -Filter * 

Foreach ($DC in $DCs)
    {
    $roles = Get-Roles $DC | select Displayname,installed,PSComputerName
    }