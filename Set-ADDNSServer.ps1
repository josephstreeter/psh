Set-DnsServerScavenging `
    -ScavengingState $true `
    -RefreshInterval 3.00:00:00 `
    -NoRefreshInterval 3.00.00.00

Set-DnsServerRecursion -Enable $false

Remove-DnsServerForwarder -IPAddress *