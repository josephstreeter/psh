#$found | % {if ($_.ip) {$_.hostname + " " + $_.ip} Else {$_.hostname}}

Foreach ($record in $found | sort hostname)
    {
    if ($record.ip) 
        {
        If ($dns = Resolve-DnsName $record.hostname -ea SilentlyContinue)
            {
            
            }
            Else
            {
            $record.hostname + " " + $record.ip
            #Add-DnsServerResourceRecorda -Name $record.hostname -IPv4Address $record.ip -ZoneName "MATC.Madison.login" -ComputerName "txdc1" -PassThru
            }
        }
    }

