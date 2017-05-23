$servers = Get-ADComputer -f {(operatingsystem -like "*server*") -and (name -ne "MCRODC")} -pr operatingsystem,lastlogondate,IPv4Address | sort name

Foreach ($Server in $Servers)
    {
    If (($Server.lastlogondate -gt $(get-date).adddays(-10)))
        {
        Get-DnsServerResourceRecord -ZoneName matc.madison.login -ComputerName txdc1 -RRType A -Name $server.name -ErrorAction 0 #| ? {($_.timestamp -gt $(Get-Date).AddDays(-5)) -and ($_.timestamp -lt $(Get-Date).AddDays(-1))}
        }
    }