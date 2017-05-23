<# Subnets - Individual Subnets #>
[array]$uwmad_classic="128.104.0.0/16","144.92.0.0/16","10.128.0.0/16"
[array]$uwmad_cs="128.105.0.0/16","198.51.254.0/24","198.133.224.0/24","198.133.225.0/24"
[array]$uwmad_resnet="146.151.0.0/17"
[array]$uwmad_wiscvpn="146.151.128.0/17"
[array]$uwmad_uwnet="72.33.0.0/16"

[array]$uwparkside="131.210.0.0/16"
[array]$uwec="137.28.0.0/16","192.133.95.0/24","192.231.219.0/24"
[array]$uwsuper="137.81.0.0/16"
[array]$uwplatt="137.104.0.0/16"
[array]$uwlax="138.49.0.0/16"
[array]$uwrf="139.225.0.0/16"
[array]$uwwwater="140.146.0.0/16"
[array]$uwoshkosh="141.233.0.0/16"
[array]$uwgb="143.200.0.0/16"
[array]$uwcolleges="143.235.0.0/16"
[array]$uwsp="143.236.0.0/16"
[array]$uwstout="144.13.0.0/16"
[array]$uwmil="129.89.0.0/16","192.107.47.0/24","192.107.164.0/24"
[array]$uwdanecoex="192.160.134.0/24"

<# Users - Individual Users #>
[array]$jstreeter = "192.168.0.100","172.16.10.100"
[array]$sttanner = "192.168.0.101"
[array]$ddenson = "192.168.0.102"

<# Hosts - Individual Hosts #>
[array]$Nagios = "192.168.0.100","172.16.10.100"
[array]$OVO = "192.168.0.101"
[array]$SEP = "192.168.0.102"

<# Networks - Groups of subnets #>
$uwmad = New-Object System.Collections.ArrayList
$uwmad += $uwmad_classic
$uwmad += $uwmad_cs
$uwmad += $uwmad_resnet
$uwmad += $uwmad_wiscvpn
$uwmad += $uwmad_uwnet

$uwsystem = New-Object System.Collections.ArrayList
$uwsystem += $uwparkside
$uwsystem += $uwec
$uwsystem += $uwsuper
$uwsystem += $uwplatt
$uwsystem += $uwlax
$uwsystem += $uwrf
$uwsystem += $uwwwater 
$uwsystem += $uwoshkosh
$uwsystem += $uwgb
$uwsystem += $uwcolleges
$uwsystem += $uwsp
$uwsystem += $uwstout
$uwsystem += $uwmil
$uwsystem += $uwdanecoex

<# Groups - Groups of users #>
$SysAdmins = New-Object System.Collections.ArrayList
$SysAdmins += $jstreeter
$SysAdmins += $sttanner
$SysAdmins += $ddenson

<# Firewall Rules #>
$rules = 
    ("Test-RDP","TCP","5933","ALLOW",($SysAdmins,$uwmad_classic)),
    ("Test-RPC","TCP","RPC","ALLOW",($UWMad)),
    ("Test-RDPEPMAP","TCP","RPCEPMAP","ALLOW",($uwmad)),
    ("Test-HTTPS","TCP","443","ALLOW",($uwsystem)),
    ("Test-HTTP","TCP","80","ALLOW",($uwsystem)),
    ("Test-FTP","TCP","21","ALLOW",($uwsp,$uwmad_classic,$SysAdmins))


Foreach ($Rule in $Rules) {
    If (Get-NetFirewallRule -name $rule[0] -ErrorAction SilentlyContinue) {Remove-NetFirewallRule -name $rule[0]}
    New-NetFirewallRule `
        -name $rule[0] `
        -DisplayName $rule[0] `
        -Enabled true `
        -Protocol $rule[1] `
        -LocalPort $rule[2] `
        -Action $rule[3] `
        -RemoteAddress $($rule[4] | % {$_ | % {$_}}) `
        -Group "SE Rules" | Out-Null
    }

get-netfirewallrule | ? {$_.name -match "test"} | ft -AutoSize

If (Get-Item "c:\scripts\advfirewallpolicy.wfw" -ea SilentlyContinue ) {Remove-Item "c:\scripts\advfirewallpolicy.wfw"}

Invoke-Expression 'netsh advfirewall export "c:\scripts\advfirewallpolicy.wfw"'

<# Run netsh advfirewall import "c:\scripts\advfirewallpolicy.wfw" at startup #>