Import-Module activedirectory

$DownServers = "C:\scripts\downservers.txt"
$ZoneDump = "C:\scripts\zonedump-$((get-date).Day).txt"
$Date = $(get-date).adddays(-10)
$AllClearRecipients = "Streeter, Joseph A<jstreeter@madisoncollege.edu>"
$ServerDownRecipients = "Streeter, Joseph A<jstreeter@madisoncollege.edu>"#,"Huber, Gary T<GTHuber@madisoncollege.edu>","Gains, Martin<MGaines@madisoncollege.edu>","Johnson, Brooks<bljohnson71@madisoncollege.edu>"#,"Stone, Tom<TStone@madisoncollege.edu>"
$servers = Get-ADComputer -f {(operatingsystem -like "*server*") -and (name -ne "MCRODC")} -pr operatingsystem,lastlogondate,IPv4Address,comment | ? {$_.lastlogondate -gt $Date} | sort name

Function Dump-ServerRecords($Servers) {
    $ARecordRpt=@()
    Get-Date | Out-File $ZoneDump
    Foreach ($Server in $Servers)
        {
        If (($Server.lastlogondate -gt $(get-date).adddays(-10)))
            {
            Foreach ($Record in Get-DnsServerResourceRecord -ZoneName matc.madison.login -ComputerName txdc1 -RRType A -Name $server.name -ErrorAction 0)
                {
                $ARecord = New-Object -Type System.Object
                $ARecord | Add-Member -MemberType NoteProperty -name HostName -value $Record.HostName
                $ARecord | Add-Member -MemberType NoteProperty -name RecordType -value $Record.RecordType
                $ARecord | Add-Member -MemberType NoteProperty -name TimeStamp -value $Record.TimeStamp
                $ARecord | Add-Member -MemberType NoteProperty -name TimeToLive -value $Record.TimeToLive
                $ARecord | Add-Member -MemberType NoteProperty -name RecordData -value $Record.RecordData.ipv4address.IPAddressToString
                $ARecordRpt += $ARecord
                }
            }
        }
    $ARecordRpt | ft -AutoSize | Out-File -Append $ZoneDump
    }

Function Send-AllClear {
    "All servers are operational $(Get-Date)" | Out-File -append "C:\Scripts\status.txt"
    Send-MailMessage `
        -To $AllClearRecipients `
        -From "Streeter, Joseph A<jstreeter@madisoncollege.edu>" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -Subject "Server DNS Record Report-All Clear" `
        -Body "This report runs hourly to check for AD joined member servers that have FQDNs that cannot be resolved by DNS" `
        -Attachments $ZoneDump
    }

Function Send-Report {
    Send-MailMessage `
        -To $ServerDownRecipients `
        -From "Streeter, Joseph A<jstreeter@madisoncollege.edu>" `
        -SmtpServer "smtp.madisoncollege.edu" `
        -Subject "Server DNS Record Report-Servers Down" `
        -Body "This report runs hourly to check for AD joined member servers that have FQDNs that cannot be resolved by DNS" `
        -Attachments $DownServers,$ZoneDump
    Remove-Item $DownServers
    }

Function Create-DNSRecords($Downrpt) {
    foreach ($Record in $Downrpt)
        {
        $DNSServer = "mcdc1"
        $Zone = "MATC.Madison.Login"
        $TTL = "0:20:00"
        $Record.Name
        $Record.ipv4address
        If ($Record.ipv4address)
            {
            Add-DnsServerResourceRecordA `
                -ComputerName $DNSServer `
                -Name $Record.name.toupper() `
                -ZoneName $Zone `
                -AllowUpdateAny `
                -TimeToLive $TTL `
                -IPv4Address $Record.ipv4address `
                -PassThru | Out-File -append "C:\Scripts\status.txt"
            }
            Else
            {
            Add-DnsServerResourceRecordA `
                -ComputerName $DNSServer `
                -Name $Record.name.toupper() `
                -ZoneName $Zone `
                -AllowUpdateAny `
                -TimeToLive $TTL `
                -IPv4Address $Record.comment `
                -PassThru | Out-File -append "C:\Scripts\status.txt"
            }
        }
    }

Function Create-Report($Servers) {
    $Downrpt=@()
    $Down=@()
    Foreach ($Server in $Servers) 
        {
        If (-not(Resolve-DnsName $Server.DNSHostName -Server MCDC1 -ea SilentlyContinue))
            {
            $Down = New-Object -Type System.Object
            $Down | Add-Member -MemberType NoteProperty -name Name -value $Server.Name
            $Down | Add-Member -MemberType NoteProperty -name DNSHostName -value $Server.DNSHostName
            $Down | Add-Member -MemberType NoteProperty -name LastLogon -value $Server.LastLogonDate
            $Down | Add-Member -MemberType NoteProperty -name Enabled -value $Server.Enabled
            $Down | Add-Member -MemberType NoteProperty -name IPv4Address -value $Server.IPv4Address
            $Down | Add-Member -MemberType NoteProperty -name Comment -value $Server.Comment
            $DownRpt += $Down
            }
        }
    "The following Servers are not resolveable by DNS`n" | Out-File $DownServers
    $DownRpt | ft -AutoSize | Out-File -append $DownServers
    Return $DownRpt
    }

Function Update-ComputerComment($Servers) {
    foreach ($Server in $Servers)
        {
        If ($Server.comment)
            {
            If ($Server.IPv4Address)
                {
                Set-ADComputer $server.name -Replace @{comment=$Server.IPv4Address}
                }
                Else
                {
                Set-ADComputer $server.name -Replace @{comment=$(resolve-dnsname $Server.name).IPAddress}
                }
            }
            Else
            {
            Set-ADComputer $server.name -add @{comment=$Server.IPv4Address} -PassThru
            }
        }
    }

Update-ComputerComment $Servers
Dump-ServerRecords $Servers
$DownServer = Create-Report $Servers
If ($DownServer)
    {
    Create-DNSRecords $DownServer
    Send-Report
    }
    Else
    {
    Send-AllClear
    }