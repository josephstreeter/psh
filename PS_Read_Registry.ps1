#get-wmiobject -class "StdRegProv" -namespace "root\default" -computername "a1-mad-01"

$Computer = "a1-mad-01"

$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Computer)

$reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
$reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters").GetValue("SysVol")
$reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion").GetValue("SystemRoot")
$reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters").GetValue("Database log files path")