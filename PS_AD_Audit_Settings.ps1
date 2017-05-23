CLS

$AdminEmail = Read-Host "Enter Administrator's email address"

$System = Get-WmiObject -class Win32_ComputerSystem

Switch ($system.DomainRole)
    {
    0 {$role = "Standalone Workstation"}
    1 {$role = "Member Workstation"}
    2 {$role = "Standalone Server"}
    3 {$role = "Member Server"}
    4 {$role = "Backup Domain Controller"}
    5 {$role = "Primary Domain Controller"}
    default {}
    }

Function Get-Settings {
"Host Name: " + $system.name + "." + $system.Domain
"`nHost OS:   " + (gwmi -class Win32_OperatingSystem).Caption
"`nHost Role: " + $role
"`n`n########################`n`n"

"`nNetwork security: Do not store LAN Manager hash value on next password change - "
$NoLMHash = (Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Lsa\" -ErrorAction Stop).NoLMHash
if ($NoLMHash -eq 1) {
    "(Enabled)"
    }Else{
    "(Disabled)" 
    }
"`n`n########################`n`n"

If (($Role -eq "Backup Domain Controller") -or ($Role -eq "Primary Domain Controller")) { 
"Check Domain Controller: LDAP Server signing requirements - "
Try {$ldapserverintegrity = (Get-ItemProperty "hklm:\System\CurrentControlSet\Services\NTDS\Parameters\" -ErrorAction stop).ldapserverintegrity}
Catch {}
if ($ldapserverintegrity -eq 0) {
    "(Not Configured)" 
    }Elseif ($ldapserverintegrity -eq 1) {
    "(None)" 
    }Elseif ($ldapserverintegrity -eq 2) {
    "(Require Signing)"
    }Else{"(Unknown)"}
    "`n`n########################`n`n"
}


"Network security: LDAP client signing requirements - "
Try {$LDAPClientIntegrity = (Get-ItemProperty "hklm:\System\CurrentControlSet\Services\LDAP\" -ErrorAction Stop).LDAPClientIntegrity}
Catch {}
if ($LDAPClientIntegrity  -eq 1) {
    "(None)" 
    }Else{
    "(Required Signing)"
    }
"`n`n########################`n`n"

"Check Network security: LAN Manager authentication level - "
Try {$LmCompatibilityLevel = (Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Lsa\" -ErrorAction Stop).LmCompatibilityLevel}
Catch {}
if ($LmCompatibilityLevel -eq 0) {
    "(Send LM & NTLM responses)"
    }Elseif ($LmCompatibilityLevel -eq 1){
    "(Send LM & NTLM - use NTLMv2 session security if negotiated)"
    }Elseif ($LmCompatibilityLevel -eq 2){
    "(Send NTLM response only)"
    }Elseif ($LmCompatibilityLevel -eq 3){
    "(Send NTLMv2 response only)"
    }Elseif ($LmCompatibilityLevel -eq 4){
    "(Send NTLM response only\refuse LM)"
    }Elseif($LmCompatibilityLevel -eq 5){
    "(Send NTLM response only\refuse LM & NTLM)"
    }Else{"(Unknown)"}
}


#$System = Get-WmiObject -class Win32_ComputerSystem
#If ("Cert:\LocalMachine\my\CN="+$System.Name+"."+$system.Domain) {"Yes"}

[string]$Message = Get-Settings

$To = "Campus Active Directory <activedirectory@doit.wisc.edu>", $AdminEmail
$From = $AdminEmail
$Subject = "DC Security Policy Report - " + $System.Name
$SmtpServer = "smtp.wiscmail.wisc.edu"
$Body = $Message.ToString()

Send-MailMessage `
    -To $To `
    -From $From  `
    -Subject $Subject `
    -Body $Body `
    -SmtpServer $SmtpServer
