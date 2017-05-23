        $DNSServer = "mcdc1"
        $Zone = "MATC.Madison.Login"
        $TTL = "0:20:00"
        $Server = "DPM2"
        $IP = "10.39.0.91"
        
        Add-DnsServerResourceRecordA -ComputerName $DNSServer -Name $Server -ZoneName $Zone -AllowUpdateAny -TimeToLive $TTL -IPv4Address $IP -PassThru