$Computers = get-adcomputer -f {name -like "vsnl-*"} -pr ipv4address
$PropArray = @()
$i=0
Foreach ($Computer in $Computers)
    {
    Write-Progress -Activity "Checkin...." -PercentComplete ($i/$computers.count)
    $DNSFwd = Resolve-DnsName $Computer.Name
    $DNSRev = Resolve-DnsName $Computer.IPv4Address -QuickTimeout
    $Prop = New-Object System.Object
    $Prop | Add-Member -type NoteProperty -name ComputerName -value $Computer.name
    $Prop | Add-Member -type NoteProperty -name ComputerIP -value $computer.ipv4address
    $Prop | Add-Member -type NoteProperty -name DNSFwdName -value $DNSFwd.name
    $Prop | Add-Member -type NoteProperty -name DNSFwdIP -value $DNSFwd.IPAddress
    $Prop | Add-Member -type NoteProperty -name DNSFwdNameHost -value $DNSRev.NameHost
    $Prop | Add-Member -type NoteProperty -name DNSRevName -value $DNSRev.Name
    $PropArray += $Prop
    $i++
    }

    $PropArray | ft -AutoSize