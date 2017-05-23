$records = "mimsvc,10.39.0.78","mimsps,10.39.0.78","mimsync,10.36.1.53","mimsvcsql,10.36.1.52","mimspssql,10.36.1.52","mimsyncsql,10.36.1.52"
$DNSServer = "txdc1"
$Zone = "MATC.Madison.Login"

foreach ($record in $records)
    {
    $Name = $record.split(",")[0]
    $Ip = $record.split(",")[1]
    
    Add-DnsServerResourceRecordA -ComputerName $DNSServer -ZoneName $Zone -Name $Name -IPv4Address $Ip -PassThru
    }