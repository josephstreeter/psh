﻿$RR = Get-ADObject -f 'objectClass -eq "DNSNode"' -SearchBase 'CN=MicrosoftDNS,DC=DomainDnsZones,DC=matc,DC=madison,dc=login' -pr dNSTombstoned,name,distinguishedName,whenchanged | Where {($_.dNSTombstoned -eq $true) -and ($_.name -NotLike "_*")} | select-object name,distinguishedName,dNSTombstoned,@{name="DateChanged";expression={$_.whenChanged.ToShortDateString()}}
$RR | group DateChanged | select count,name | sort name | ft -AutoSize