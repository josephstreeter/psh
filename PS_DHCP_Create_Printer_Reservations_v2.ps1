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

Function Get-PrinterQueues {
$PrintServers = "PSTXLAB01.MATC.Madison.Login","PSFS01.MATC.Madison.Login"
$PrinterReport = @()
foreach ($PrintServer in $PrintServers)
    {
    $Printers = Get-Printer -ComputerName $PrintServer | select printerstatus, name, computername
    foreach ($Printer in $Printers)
        {
        $Prt = New-Object -TypeName System.Object
        $prt | Add-Member -MemberType NoteProperty -name Name -Value $Printer.Name
        $prt | Add-Member -MemberType NoteProperty -name Status -Value $Printer.Printerstatus
        $prt | Add-Member -MemberType NoteProperty -name Server -Value $Printer.ComputerName
        $PrinterReport += $Prt
        }
    }
Return $PrinterReport
}

Function Create-Reservations($ActiveLeases, $Printers, $ReportNoLease) {
$NoLeaseReport=@()
foreach ($printer in $Printers)
    {
    $reservation = $ActiveLeases | ? {$_.hostname -match $printer.name}
    if ($Reservation.hostname)
        {
        #"Netsh dhcp server scope " + $Reservation.Scope.Trim() + " add reservedip " + $Reservation.IPAddress.Trim() + " " + $Reservation.MACAddress + " " + $Reservation.hostname
        "Netsh dhcp server scope $($Reservation.Scope.Trim()) add reservedip $($Reservation.IPAddress.Trim()) $($Reservation.MACAddress) $($Reservation.hostname)"
        }
        Else
        {
        $NoLease = New-Object -TypeName System.Object
        $NoLease | Add-Member -MemberType NoteProperty -name Name -Value $Printer.Name
        $NoLease | Add-Member -MemberType NoteProperty -name Status -Value $Printer.Status
        $NoLease | Add-Member -MemberType NoteProperty -name Server -Value $Printer.Server
        $NoLeaseReport += $NoLease
        }
    }
    $NoLeaseReport | Out-File -append $ReportNoLease
}

Function Send-Reports($ReportReservations,$ReportNoLease) {
Send-MailMessage `
    -to jstreeter@madisoncollege.edu `
    -from jstreeter@madisoncollege.edu `
    -Subject "Printer Reservation Reports" `
    -Attachments $ReportReservations,$ReportNoLease `
    -smtp "smtp.madisoncollege.edu"
}

$ReportReservations = "C:\Scripts\Printers-Reservations.txt"
Get-Date | Out-File $ReportReservations
$ReportNoLease = "C:\Scripts\Printers-No-Lease.txt"
Get-Date | Out-File $ReportNoLease

"Retrieving DHCP Leases"
#$ActiveLeases = Get-DHCPLeases
"Retrieving Print Queues"
#$Printers = Get-PrinterQueues
"Creating Reports"
Create-Reservations $ActiveLeases $Printers $ReportNoLease | Out-File $ReportReservations
"Sending Reports"
Send-Reports $ReportReservations $ReportNoLease