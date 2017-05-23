Function Get-DHCPLeases {
$Scopes = netsh dhcp server 10.39.0.119 show scope
$LeaseReport = @()

foreach ($Scope in $Scopes)
    {
    $Leases = (netsh dhcp server 10.39.0.119 scope $Scope.split("-")[0].trim() show clients 1) | Select-String "-D-" 
    
    foreach ($Lease in $Leases) 
        {
        If ($Lease -notmatch "NEVER EXPIRES")
            {
            $Info = New-Object -type System.Object
            $Hostname = $Lease.tostring().replace("-D-",";").Split(";").Trim()
            $Info | Add-Member -MemberType NoteProperty -name Hostname -Value $Hostname[1]
            $IP = $Hostname[0].replace(" - ",";").Split(";")
            $Info | Add-Member -MemberType NoteProperty -name Scope -Value $Scope.split("-")[0].trim()
            $Info | Add-Member -MemberType NoteProperty -name IPAddress -Value $IP[0]
            $Info | Add-Member -MemberType NoteProperty -name SubnetMask -Value $IP[1]
            $Info | Add-Member -MemberType NoteProperty -name MACAddress -Value $IP[2].replace(" -",";").Split(";")[0].Trim()
            $LeaseReport += $Info
            }
        }

    }
Return $LeaseReport
}

Function Get-Printers {

$printers = get-printer -ComputerName PSfS01
Return $printers
}

Function Create-Reservations($ActiveLeases, $Printers) {
foreach ($printer in $Printers)
    {
    $reservation = $ActiveLeases | ? {$_.hostname -match $printer.name}
    if ($Reservation.hostname)
        {
        "-------------------------------------------------------------"
        #"Netsh dhcp server scope " + $Reservation.Scope.Trim() + " add reservedip " + $Reservation.IPAddress.Trim() + " " + $Reservation.MACAddress + " " + $Reservation.hostname
        "Netsh dhcp server scope $($Reservation.Scope.Trim()) add reservedip $($Reservation.IPAddress.Trim()) $($Reservation.MACAddress) $($Reservation.hostname)"
        }
    }
}

"Retrieving DHCP Leases"
$ActiveLeases = Get-DHCPLeases
"Retrieving Print Queues"
$Printers = Get-Printers
Create-Reservations $ActiveLeases $Printers