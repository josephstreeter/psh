$servers=Get-ADComputer -f * -SearchBase "ou=servers,dc=matc,dc=madison,dc=login"

foreach ($Server in $Servers)
    {
    If (Test-Connection -ComputerName $Server.DNSHostName -Count 1 -ErrorAction SilentlyContinue)
        {
        "`n$($Server.DNSHostName)"
        [string]$secedit=Invoke-Command `
            -ComputerName $Server.DNSHostName `
            -ScriptBlock {secedit /export /cfg c:\secpol_local.txt /areas USER_RIGHTS;gc c:\secpol_local.txt;rm c:\secpol_local.txt} | select-string 'SeServiceLogonRight'
        $objects = $secedit.Split("=")[1].Split(",")
        foreach ($object in $objects)
            {
            [string]$SID=$($object.tostring().replace("*","").trim())
            Get-ADObject -f {objectSID -eq $sid} | select name
            }
        }
    }