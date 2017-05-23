CLS
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

$Message = (
$system.name + "." + $system.Domain
(gwmi -class Win32_OperatingSystem).Caption
$role

Write-Host '"Network security: Do not store LAN Manager hash value on next password change"'
$NoLMHash = (Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Lsa\" -ErrorAction Stop).NoLMHash
if ($NoLMHash -eq 1) {
    Write-Host "Enabled" -ForegroundColor Green
    }Else{
    Write-Host "Disabled" -ForegroundColor Red
    }

If (($Role -eq "Backup Domain Controller") -or ($Role -eq "Primary Domain Controller")) { 
Write-Host 'Check "Domain Controller: LDAP Server signing requirements"'
Try {$ldapserverintegrity = (Get-ItemProperty "hklm:\System\CurrentControlSet\Services\NTDS\Parameters\" -ErrorAction stop).ldapserverintegrity}
Catch {}
if ($ldapserverintegrity -eq 0) {
    Write-Host "Not Configured" -ForegroundColor Red
    }Elseif ($ldapserverintegrity -eq 1) {
    Write-Host "None" -ForegroundColor Red
    }Elseif ($ldapserverintegrity -eq 2) {
    Write-Host "Require Signing" -ForegroundColor Green
    }Else{Write-Host "Unknown" -ForegroundColor Yellow}
}

Write-Host '"Network security: LDAP client signing requirements"'
Try {$LDAPClientIntegrity = (Get-ItemProperty "hklm:\System\CurrentControlSet\Services\LDAP\" -ErrorAction Stop).LDAPClientIntegrity}
Catch {}
if ($LDAPClientIntegrity  -eq 1) {
    Write-Host "None" -ForegroundColor Red
    }Else{
    Write-Host "Required Signing" -ForegroundColor Green
    }

Write-Host 'Check "Network security: LAN Manager authentication level"'
Try {$LmCompatibilityLevel = (Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Lsa\" -ErrorAction Stop).LmCompatibilityLevel}
Catch {}
if ($LmCompatibilityLevel -eq 0) {
    Write-Host "Send LM & NTLM responses" -ForegroundColor Red
    }Elseif ($LmCompatibilityLevel -eq 1){
    Write-Host "Send LM & NTLM - use NTLMv2 session security if negotiated" -ForegroundColor Red
    }Elseif ($LmCompatibilityLevel -eq 2){
    Write-Host "Send NTLM response only" -ForegroundColor Red
    }Elseif ($LmCompatibilityLevel -eq 3){
    Write-Host "Send NTLMv2 response only" -ForegroundColor Red
    }Elseif ($LmCompatibilityLevel -eq 4){
    Write-Host "Send NTLM response only\refuse LM" -ForegroundColor Red
    }Elseif($LmCompatibilityLevel -eq 5){
    Write-Host "Send NTLM response only\refuse LM & NTLM" -ForegroundColor Green
    }Else{"unknown"}
)


$To = "Campus Active Directory <activedirectory@doit.wisc.edu>" 
$From = "Campus Active Directory <activedirectory@doit.wisc.edu>"
$Subject = "DC Security Policy Report - $System.Name"
$SmtpServer = "smtp.wiscmail.wisc.edu"
$Body = $Message.ToString()

Send-MailMessage `
    -To $To `
    -From $From  `
    -Subject $Subject `
    -Body $Body `
    -SmtpServer $SmtpServer
