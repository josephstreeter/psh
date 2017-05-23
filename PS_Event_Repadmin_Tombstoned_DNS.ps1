$Servers = "DPM2"

Foreach ($Server in $Servers)
    {
    $Server
    "___________________"
    repadmin /showmeta "DC=$Server,DC=MATC.Madison.Login,CN=MicrosoftDNS,DC=DomainDnsZones,DC=MATC,DC=Madison,DC=Login" mcdc1 | Select-String "dns"
    

    
    $Events = Get-WinEvent -ComputerName mcdc3 -FilterHashtable @{Logname='Security';Id=5136} -MaxEvents 100
    $List = @()

    ForEach ($Event in $Events) {
        $eventXML = [xml]$Event.ToXml()
        $EL = New-Object -type system.object
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[8].name -Value ($eventxml.Event.EventData.data[8].'#text').split(",")[0]
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[10].name -value $eventxml.Event.EventData.data[10].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[13].name -value $eventxml.Event.EventData.data[13].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[3].name -value $eventxml.Event.EventData.data[3].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[4].name -value $eventxml.Event.EventData.data[4].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name SystemTime -value ($eventXML.Event.System.TimeCreated.SystemTime).Split(".")[0]
        $List += $EL
        }

        $file = $env:computername + ".txt"

        $list | ? {($_.objectclass -eq "dnsnode") -and ($_.objectDN -match $Server)} | ft -AutoSize #| out-file \\txdc1.matc.madison.login\c$\$file
    }