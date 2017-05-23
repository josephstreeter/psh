$CurrentProfile = netsh advfirewall Monitor show currentprofile

if (-not ($CurrentProfile | Select-String $(Get-WmiObject -Class Win32_ComputerSystem).domain)) {
    $NIC = Get-WmiObject -Class win32_networkadapter -ComputerName -filter "AdapterType = 'Ethernet 802.3'"
    $NIC.disable()
    $NIC.enable()
    
    $path = "HKLM:\System\CurrentControlSet\services\eventlog\System"
    If (-not ($(gci $path -Name) -contains "NLA-Change")) {Try {New-EventLog -LogName "System" -Source "NLA-Change"} Catch {Break}}
    
    Try {Write-EventLog -LogName "System" -Source "NLA-Change" -EventId "1234" -EntryType "Warning" -Message "NLA Location was updated"} Catch {Break}
    }