$records = Get-DnsServerResourceRecord -ComputerName TXDC1 -ZoneName madisoncollege.edu -RRType A 
$PropArray = @()
$RecordCount = $records.Count
foreach ($record in $records)
    {
    $RecordCount ; --$RecordCount
    $Prop = New-Object System.Object
    $Prop | Add-Member -type NoteProperty -name HostName -value $Record.HostName
    If ($(Ping $record.RecordData.IPv4Address -n 1 -w 1) -match "Reply From")
        {
        $Prop | Add-Member -type NoteProperty -name Status -value "up"
        }
        Else
        {
        $Prop | Add-Member -type NoteProperty -name Status -value "down"
        }
    $Prop | Add-Member -type NoteProperty -name IPAddress -value $record.RecordData.IPv4Address
    $PropArray += $Prop
    }
    $PropArray | ? {$_.status -eq "down"} | ft