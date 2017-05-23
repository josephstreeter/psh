$Hostnames = @(91)

$DNSServer = "mcdc5"
$Zone = "255.181.10.in-addr.arpa"
$TTL = "0:20:00"

Foreach ($Hostname in $Hostnames) 
    {
    $record = Get-DnsServerResourceRecord -ComputerName $DNSServer -ZoneName $Zone -RRType PTR | ? { $_.hostname -eq $HostName } 

    If ($record) 
        {
        $record | Remove-DnsServerResourceRecord -ComputerName $DNSServer -ZoneName $Zone -PassThru -Force
        Add-DnsServerResourceRecordPTR -ComputerName $DNSServer -Name $record.Hostname -ZoneName $Zone -AllowUpdateAny -TimeToLive $TTL -PTRDomainName $record.RecordData.PtrDomainName
        }
    }