$a=0
$b=0
$servers = Get-ADComputer -f {(operatingsystem -like "*server*") -and (name -ne "MCRODC")} -pr operatingsystem,lastlogondate,IPv4Address,comment | ? {$_.lastlogondate -gt $Date} | sort name
$servers | ? {$_.operatingsystem -match "2008"} | select name,operatingsystem | % {If (Invoke-Command -ComputerName $_.name -ScriptBlock {gpupdate /force /target:computer}){$a++}Else{$b++} ; CLS ; "Success: " + $a ; "Failed:  " + $b}