$DCs = $((Get-ADDomainController -filter {(-not(hostname -eq "MCRODC.MATC.Madison.Login")) -and (-not(hostname -eq "MDCSYNC.MATC.Madison.Login"))}).hostname)
$a = @()

Foreach ($DC in $DCs) 
    {
    Invoke-Command -comp $DC -ScriptBlock {
        ""
        "Server     " + (gwmi win32_computersystem).name.trim()
        "OS Version " + (gwmi win32_operatingsystem).version
        "Role       " + (gwmi win32_computersystem).domainrole
        <#"bios       " + (Get-WmiObject -Class win32_bios).SMBIOSBIOSVersion
        "processor  " + (Get-WmiObject -Class win32_Processor)
        "memory     " + (Get-WmiObject -Class win32_physicalmemory)
        "volume     " + (Get-WmiObject -Class win32_volume)#>
        "No LM Hash " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Control\Lsa")."NoLMHash"
        "SignedLDAP " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Services\LDAP")."LDAPClientIntegrity"
        "LDAPInteg  " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters")."ldapserverintegrity"
        "LMAuthLvl  " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Control\Lsa")."LmCompatibilityLevel"
        "Database   " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters\")."DSA Working Directory"
        "SYSVOL     " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\")."SysVol"
        "System     " + (Get-Itemproperty -path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\")."SystemRoot"
        "Logs       " + (Get-Itemproperty -path "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters\")."Database log files path"
        "NTPServer  " + (Get-Itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\Parameters\" -ea silentlycontinue)."NTPServer"
        "Type       " + (Get-Itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\Parameters\" -ea silentlycontinue)."Type"
        } -UseSSL
    }