#$printer = get-printer -ComputerName PSfs01

foreach ($print in $Printer)
    {
    $reservation = $LeaseReport | ? {$_.hostname -match $print.name}
    if ($Reservation.Hostname)
        {
        "Netsh dhcp server scope 10.120.11.0 add reservedip " + $Reservation.IPAddress.Trim() + " " + $Reservation.MACAddress + " " + $reservation.hostname
        }
    }