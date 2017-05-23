$Printers = get-printer -ComputerName PSTXLAB01.MATC.Madison.Login -name MB1618-M9060M #| select -First 40

foreach ($Printer in $Printers)
    {
    foreach ($Lease in $LeaseReport)
        {
        If ($Lease.hostname -match $Printer.PortName)
            {
            $Printer.PortName
            $Scope = $Lease.ipaddress.Split(".")[0] + "." + $Lease.ipaddress.Split(".")[1] + "." + $Lease.ipaddress.Split(".")[2] + ".0"
                netsh dhcp server 10.39.0.119 scope $($Scope.trim()) add reservedip $($Lease.ipaddress.trim()) $($Lease.macaddress.replace('-','')) $($Lease.hostname)
            }
        }
    }