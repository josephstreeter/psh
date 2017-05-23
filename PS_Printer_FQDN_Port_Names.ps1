$Queues = (Get-ADObject -f 'objectClass -eq "printqueue"' -pr servername)


foreach ($Queue in $Queues | select -first 10)
    {
    $Queue | 
    gwmi -comp $queue.Servername -Class Win32_Printer -pr portname | ? {$_.portname -notmatch "10.{1,3}.{1,3}.{1,3}"} | % {If (-not(Resolve-DnsName $_.portname -ea 0)){$_.portname}}
    #(Resolve-DnsName $server.dnshostname).IPAddress
    }
