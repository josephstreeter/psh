
$Servers=$(Get-ADComputer -filter {name -like "PRTG*"}).name #$Servers=$(Get-ADDomainController -filter *).hostname
$Script="C:\Scripts\PS_Windows_Update.ps1"
$cred = Get-Credential MATCMadison\jstreeter_a

foreach ($Server in $Servers)
    {
    $Server
    Try {$session=New-PSSession -ComputerName $Server}
    Catch {"Failed to connect to $Server"}
    if ($session)
        {
        Invoke-Command -Session $Session -FilePath $Script -ArgumentList $cred -AsJob  | Out-Null
        Clear-Variable Session
        }
    }

do
    {
    Clear-Host
    $jobs=Get-Job | ? {$_.State -eq "Running"}
    $Jobs
    sleep -Seconds 5
    }
while ($($Jobs.count) -gt 0)

Clear-Variable cred
Get-Job | Remove-Job