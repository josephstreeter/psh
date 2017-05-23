If ((Get-Service WinRM).status -eq "Stopped") {Start-Service WinRM}

$DNSName = $(Get-WmiObject -class win32_computersystem).name + "." + $(Get-WmiObject -class win32_computersystem).domain
$Name = $(Get-WmiObject -class win32_computersystem).name

$cert = New-SelfSignedCertificate -DnsName $ENV:COMPUTERNAME, "$env:COMPUTERNAME.$env:USERDNSDOMAIN".ToLower() -CertStoreLocation Cert:\LocalMachine\My
$Config = '@{Hostname="' + $ENV:COMPUTERNAME + '";CertificateThumbprint="' + $cert.Thumbprint + '"}'
winrm create winrm/config/listener?Address=*+TransPort=HTTPS $Config

#winrm e winrm/config/listener

If (-Not(get-netfirewallrule "Windows Remote Management (HTTPS-In)")) {
    New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP
    }

# winrm delete winrm/config/listener?Address=*+Transport=HTTPS
