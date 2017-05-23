$ClientRpt=@()
Foreach ($DC in $(Get-ADDomainController -Filter * | % {If ($("TXDC1","MCDC5","MCRODC") -notcontains $_.name) {$_.hostname}}))
    {
    If (get-item "\\$dc\c$\dns.log")
        {
        $Entries = gc "\\$dc\c$\dns.log" | select-string "remote addr" | % {$_ -replace "Remote addr" -replace ", port (\d{0,9})" } | sort -Unique
        foreach ($Entry in $Entries)
            {
            $Client = New-Object -type System.Object
            $Client | Add-Member -type noteproperty -name ip -value $Entry
            $Client | Add-Member -type noteproperty -name DC -value $DC
            $ClientRpt += $Client
            }
        }
    }
$ClientRpt | ft -AutoSize