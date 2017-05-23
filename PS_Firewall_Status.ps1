foreach ($DC in $(Get-ADDomainController -Filter {(name -notlike "*RODC*")}).hostname)
    {
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$dc)
    Try {$firewallEnabled = $reg.OpenSubKey("System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile").GetValue("EnableFirewall")}
    Catch {$firewallEnabled = "Not available"}
    $DC + "   " + [bool]$firewallEnabled
    }