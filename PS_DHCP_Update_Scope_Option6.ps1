Foreach ($Scope in $(netsh dhcp server 10.181.255.24 show scope | % {$_.split("-")[0].trim()} | ? {$_ -match 10.}))
    {
        netsh dhcp server 10.181.255.24 scope $Scope set optionvalue 006 IPADDRESS 10.39.0.111 10.39.0.112
    }