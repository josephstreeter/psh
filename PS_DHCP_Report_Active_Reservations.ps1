#$Leases = Get-DhcpServerv4Scope -ComputerName dhcpprd01 | Get-DhcpServerv4Lease -ComputerName dhcpprd01 
$file = "C:\Scripts1\dhcp_report.txt"

Function Create-DHCPReservationReport
    {
    $PropArray = @()
    Foreach ($Lease in $Leases)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name IPAddress -value $Lease.IPAddress
        $Prop | Add-Member -type NoteProperty -name ScopeId -value $Lease.ScopeId
        $Prop | Add-Member -type NoteProperty -name ClientId -value $Lease.ClientId
        $Prop | Add-Member -type NoteProperty -name HostName -value $Lease.HostName
        $Prop | Add-Member -type NoteProperty -name AddressState -value $Lease.AddressState
        $PropArray += $Prop
        }

    "`nInactive Reservations"
    $PropArray | Where-Object {$_.addressstate -eq "InActiveReservation"} | ft -AutoSize
    "`nActive Reservations"
    $PropArray | Where-Object {$_.addressstate -eq "ActiveReservation"} | ft -AutoSize
    "`nDeclined Leases"
    $PropArray | Where-Object {$_.addressstate -eq "Declined"} | ft -AutoSize
    }

Function Send-DHCPReservationReport
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body "See attached report" `
        -Subject "DHCP Reservation Report" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -attachment $File
    Remove-Item $File
    }

Create-DHCPReservationReport | Out-File $file
Send-DHCPReservationReport