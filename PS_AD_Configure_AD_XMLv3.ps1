
#Get-Variable * -Scope Global | Remove-Variable -ea SilentlyContinue
$Path = "c:\scripts\inventory.xml"

Function Select-Adapter {
    CLS
    $Nics = Get-NetAdapter
    
    $i = -1
    $Interfaces=@()
    Foreach ($Nic in $Nics){
        $i++
        $TCPIP = $Nic | Get-NetIPAddress -ea silentlycontinue
        $Interface = New-Object System.Object
        $Interface | Add-Member -type NoteProperty -Name Int -Value $i
        $Interface | Add-Member -type NoteProperty -Name Name -Value $Nic.Name
        $Interface | Add-Member -type NoteProperty -Name Desc -Value $Nic.InterfaceDescription
        $Interface | Add-Member -type NoteProperty -Name IfIndex -Value $Nic.ifIndex
        $Interface | Add-Member -type NoteProperty -Name Status -Value $Nic.Status
        $Interface | Add-Member -type NoteProperty -Name LinkSpeed -Value $Nic.LinkSpeed
        $Interface | Add-Member -type NoteProperty -Name IPv4Address -Value $TCPIP.IPv4Address
        $Interface | Add-Member -type NoteProperty -Name IPv6Address -Value $TCPIP.IPv6Address
        $Interfaces += $Interface
        }
    
    $interfaces | ft -AutoSize

    $SelectedNic = Read-Host "Select an Interface to configure"
        
        "Selected Interface"
        "Interface Number:                 " + $Interfaces[$SelectedNic].Int
        "Interface Name:                   " + $Interfaces[$SelectedNic].Name
        "Interface Desc:                   " + $Interfaces[$SelectedNic].Desc
        "Interface index:                  " + $Interfaces[$SelectedNic].IfIndex
        "Interface Status:                 " + $Interfaces[$SelectedNic].Status
        "Interface Link Speed:             " + $Interfaces[$SelectedNic].LinkSpeed
        "Interface IPv4 Address:           " + $Interfaces[$SelectedNic].IPv4Address
        "Interface IPv6 Address:           " + $Interfaces[$SelectedNic].IPv6Address#>
        ""
    If ($(Read-Host "Is this the correct interface [yes/no]?") -like "y*"){
        $Global:SelectedInterface = $Interfaces[$SelectedNic].ifIndex
        }Else{
        Configure-Adapter
        }
    Create-XMLFile
    Show-Information

    }
    
Function Get-HostName {
    CLS 
    $RenameHost = Read-Host "Do you want to rename this host (Requires a reboot)"
    If ($RenameHost -like "Y*") {$HostName = Read-Host "Enter new host name"}
    $Global:HostName
    Create-XMLFile
    Show-Information
    }

Function Get-IPAddress {
    CLS
    $IPAddress = Read-Host "Enter IP Address"
    Create-XMLFile
    Show-Information
    }

Function Get-IPPrefix {
    CLS
    $Global:Prefix = Read-Host "Enter Prefix [24]"
    If (!($Prefix)){$Global:Prefix = 24}
    Create-XMLFile
    Show-Information
    }

Function Get-IPDefaultGateway {
    CLS
    $Global:DefaultGateWay = Read-Host "Enter default gateway"
    Create-XMLFile
    Show-Information
    }

Function Get-IPDNSServers {
    CLS
    $Global:DNSServer = Read-Host "Enter Secondary DNS Server"
    Create-XMLFile
    Show-Information
    }

Function Get-DNSDomainName {
    CLS
    $Global:FQDN = Read-Host "Enter Fully Qualified Domain Name"
    Create-XMLFile
    Show-Information
    }

Function Get-DomainName {
    CLS
    $Global:DomainName = Read-Host "Enter NetBIOS Domain Name"
    Create-XMLFile
    Show-Information
    }

Function Get-SafeModePassword {
    CLS
    $Global:SafeModePassword = Read-Host "Enter Safe Mode Admin Password"
    Create-XMLFile
    Show-Information
    }

Function Get-SYSVOLDrive {
    CLS
    $SYSVOLDrive = "D:"
    $SYSVOLDrive = Read-Host "Enter drive letter for SYSVOL [D:]"
    If (!($SYSVOLDrive)){$SYSVOLDrive = "D:"}
    $Global:SYSVOLPath = "$SYSVOLDrive\SYSVOL"
    Create-XMLFile
    Show-Information
    }

Function Get-NTDSDrive {
    CLS
    $NTDSDrive = "D:"
    $NTDSDrive = Read-Host "Enter drive letter for NTDS [D:]"
    If (!($NTDSDrive)){$NTDSDrive = "D:"}
    $Global:NTDSPath = "$NTDSDrive\NTDS"
    Create-XMLFile
    Show-Information
    }

Function Get-LogsDrive {
    CLS
    $LogsDrive = "L:"
    $LogsDrive = Read-Host "Enter drive letter for Logs [L:]"
    If (!($LogsDrive)){$LogsDrive = "L:"}
    $Global:LogsPath = "$LogsDrive\Logs"
    Create-XMLFile
    Show-Information
    }
     
Function Get-StaticNETLOGON { 
    CLS
    $NETLOGON = Read-Host "Enter static port for Netlogon Service [520000]"
    If (!($NETLOGON)){$NETLOGON = 520000}
    Create-XMLFile
    Show-Information
    }

Function Get-StaticNTFRS {
    CLS
    $FileRep = Read-Host "Enter static port for NTFRS Service [520001]"
    If (!($FileRep)){$FileRep = 520001}
    Create-XMLFile
    Show-Information
    }

Function Get-AllowRDP {
    CLS
    $AllowRDP = Read-Host "Enable Remote Desktop Protocol? (Yes/No) [Yes]"
    If (!($AllowRDP)){$AllowRDP = "Yes"}
    Create-XMLFile
    Show-Information
    }

Function Get-SecureRDP {
    CLS
    $SecureRDP = Read-Host "Enable Secure RDP? (Yes/No) [Yes]"
    If (!($SecureRDP)){$SecureRDP = "Yes"}
    Create-XMLFile
    Show-Information
    }

Function Get-NewForest {
    CLS
    $NewForest = Read-Host "Is this a new Forest? (Yes/No) [Yes]"
    If (!($NewForest)){$NewForest = "Yes"}    
    Create-XMLFile
    Show-Information
    }

Function Configure-NetworkInterface {
    New-NetIPAddress `
        -InterfaceIndex $Config.AD.Host.Interface `
        -IPAddress $Config.AD.Host.IPAddress `
        -PrefixLength $Config.AD.Host.Prefix `
        -DefaultGateway $Config.AD.Host.DefaultGateway

    Set-DnsClientServerAddress `
        -InterfaceIndex $Config.AD.Host.Interface `
        -ServerAddresses ($Config.AD.Host.DNSServer) `
        -PassThru

    Set-DnsClient `
        -InterfaceIndex $Config.AD.Host.Interface `
        -UseSuffixWhenRegistering $true `
        -RegisterThisConnectionsAddress $True `
        -ConnectionSpecificSuffix $Config.AD.Forest.FQDN `
        -PassThru

    Set-DnsClientGlobalSetting `
       -SuffixSearchList $Config.AD.Forest.FQDN `
       -PassThru
    }

Function Configure-Storage {
    Write-Host "Configure Volume Labels"     
    If (Get-Volume C -ea SilentlyContinue){
        Set-Volume -driveletter C -NewFileSystemLabel "System" -PassThru
        }Else{ 
        Write-Host -ForegroundColor Red "C: drive does not exit`n"
        }
        
    If (Get-Volume L -ea SilentlyContinue){
        Set-Volume -driveletter L -NewFileSystemLabel "Logs" -PassThru
        }Else{ 
        Write-Host -ForegroundColor Red "L: drive does not exit`n"
        }

    If (Get-Volume D -ea SilentlyContinue){
        Set-Volume -driveletter D -NewFileSystemLabel "Database" -PassThru
        }Else{
        Write-Host -ForegroundColor Red "D: drive does not exit`n"        
        }
    }

Function Configure-RDP {
    $RDP = Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices
    If ($RDP.AllowTsConnections -eq 0){
        $RDP.SetAllowTsConnections(1)
        Write-Host -ForegroundColor Green "Remote Desktop Protocol is now configured`n"
        }Else{
        Write-Host -ForegroundColor Green "Remote Desktop Protocol already configured`n"
        }


    $RDPNLA = Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"
    If ($RDPNLA.UserAuthenticationRequired -eq 0){
        $RDPNLA.SetUserAuthenticationRequired(1)
        Write-Host -ForegroundColor Green "Network Level Authentication is now configured`n"
        }Else{
        Write-Host -ForegroundColor Green "Network Level Authentication already configured`n"
        }
    }

Function Configure-HostName {
    If ($Config.AD.Host.RenameHost -like "y*"){
        Rename-Computer -NewName $Config.AD.Host.HostName -force 
        If ($(Read-Host "Reboot now? (Yes/No)") -like "y*"){Restart-Computer}
        }
    }

Function Configure-StaticPorts {
    
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine","localhost")

    $Key = $Reg.OpenSubKey("SYSTEM\CurrentControlSet\Services\NTDS\Parameters",$true)
    $Key.SetValue("TCP/IP Port",$NTDSPort,"DWORD")

    #Get-Service NTDS | Restart-Service -Force

    $Key = $Reg.OpenSubKey("SYSTEM\CurrentControlSet\Services\Netlogon\Parameters",$true)
    $Key.SetValue("DCTCPIPPort",$NetLoginPort,"DWORD")

    #Get-Service NetLogon | Restart-Service -Force

    If ((Get-Service NTFRS).status -eq "Running"){
        $Key = $Reg.OpenSubKey("SYSTEM\CurrentControlSet\Services\NTFRS\Parameters",$true)
        $Key.SetValue("RPC TCP/IP Port Assignment",$NTFRSPort,"DWORD")
        #Get-Service NTFRS | Restart-Service -Force
        }

    If ((Get-Service DFSR).status -eq "Running"){
        dfsrs.exe /StaticRPC "localhost" /Port:$DFSRPort /Member:"localhost"
        #Get-Service DFSR | Restart-Service -Force
        }
    }

Function Create-StoragePaths {
    Try {If (-not(get-item $Info.DataBasePath.split("\")[0] -ea silentlycontinue)) {
	        $Info.DataBasePath.split("\")[0] + " drive doesn't exist"
            Exit
	        }Else {
	        If (-not(get-item $Info.DataBasePath -ea silentlycontinue)) {
		        New-Item $Info.DataBasePath -type Directory
	            }
	        }
        }
    Catch {$?;Exit}

    Try {If (-not(get-item $Info.SysVolPath.split("\")[0] -ea silentlycontinue)) {
	        $Info.SysVolPath.split("\")[0] + " drive doesn't exist"
	        Exit
            }Else{
	            If (-not(get-item $Info.SysvolPath -ea silentlycontinue)) {
		            New-Item $Info.SysvolPath -type Directory
	                }
	        }
        }
    Catch {$?;Exit}

    Try {If (-not(get-item $Info.LogPath.split("\")[0] -ea silentlycontinue)) {
	        $Info.LogPath.split("\")[0] + " drive doesn't exist"
            Exit
	        }Else{
	            If (-not(get-item $Info.LogPath -ea silentlycontinue)) {
		        New-Item $Info.LogPath -type Directory
	            }
	        }
        }
    Catch {$?;Exit}
    
    Show-ForestMenu
    }

Function Install-ADDSRoles {
    #Add-WindowsFeature -Name "adds-domain-controller " -IncludeAllSubFeature -IncludeManagementTools # WS 2012
    Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools # WS 2008
    Add-WindowsFeature -Name "DNS" -IncludeAllSubFeature -IncludeManagementTools
    Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools
    }

Function New-Forest2012 {
    Import-Module ADDSDeployment
    Try{Install-ADDSForest `
        -DomainMode "Win2012R2" `
        -ForestMode "Win2012R2" `
        -SafeModeAdministratorPassword $($Config.AD.Forest.SafeModePassword | ConvertTo-SecureString -AsPlainText -Force) `
        -InstallDns:$true `
        -NoRebootOnCompletion:$True `
        -CreateDnsDelegation:$false `
        -DomainName $Config.AD.Forest.FQDN `
        -DomainNetbiosName $Config.AD.Forest.DomainName `
        -DatabasePath $Config.AD.Forest.NTDSPath `
        -LogPath $Config.AD.Forest.LogsPath `
        -SysvolPath $Config.AD.Forest.SYSVOLPath `
        -SkipPreChecks `
        -Force:$true
        }
    Catch {$Error[0];pause;exit}
    }

Function Create-OUStructure {
    $DomainDN = $((get-addomain).distinguishedname)

    Write-Host "Create Enterprise Organizational Unit"
    New-ADOrganizationalUnit -Name "ENT" -path $DomainDN -PassThru
    New-ADOrganizationalUnit -Name "Dept Admins" -path "OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Users" -path "OU=Dept Admins,OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Groups" -path "OU=Dept Admins,OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Groups" -path "OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Servers" -path "OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Users" -path "OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Sensitive Objects" -path "OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Users" -path "OU=Sensitive Objects,OU=ENT,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Groups" -path "OU=Sensitive Objects,OU=ENT,$DomainDN" -PassThru

    Write-Host "Create Wisc Organizational Unit"
    New-ADOrganizationalUnit -Name "Wisc" -path $DomainDN -PassThru
    New-ADOrganizationalUnit -Name "Users" -path "OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "NetID" -path "OU=Users,OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Inactive" -path "OU=Users,OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "GuestNetID" -path "OU=Users,OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Groups" -path "OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Manifest" -path "OU=Groups,OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "UDDS" -path "OU=Groups,OU=Wisc,$DomainDN" -PassThru
    New-ADOrganizationalUnit -Name "Delegation" -path "OU=Groups,OU=Wisc,$DomainDN" -PassThru

    Write-Host "Create OrgUnits Organizational Unit"
    New-ADOrganizationalUnit -Name "orgUnits" -path $DomainDN -PassThru
    New-ADOrganizationalUnit -Name "Computers" -path "OU=orgUnits,$DomainDN" -PassThru

    Write-Host "Set default Computer object location"
    redircmp "OU=Computers,OU=orgUnits,$DomainDN"
}

Function Move-SensitiveObjects {
    $DomainDN = (Get-ADDomain).distinguishedname 

    $SObjects = @(
        "Domain Admins"
        "Enterprise Admins"
        "Group Policy Creator Owners"
        "Schema Admins"
        "Administrator"
        )

    Foreach ($SObject in $SObjects){
        $object = get-adobject -filter {name -eq $SObject} -pr objectclass
        If ($Object.ObjectClass -eq "Group"){
            Move-ADObject $Object.DistinguishedName -TargetPath "ou=groups,ou=sensitive objects,ou=ent,$DomainDN" -PassThru
            }Else{
            Move-ADObject $Object.DistinguishedName -TargetPath "ou=users,ou=sensitive objects,ou=ent,$DomainDN" -PassThru
            }
        }
    }

Function Configure-OUACLs {
    $DomainDN = $(Get-ADDomain).distinguishedName
    $DomainName = $(Get-ADDomain).Name
    $sdholder = $(Get-adobject "CN=AdminSDHolder,CN=System,$((Get-ADDomain).distinguishedName)").DistinguishedName
    $ENTOU = "ou=sensitive objects,ou=ent,$DomainDN"
    $WiscOU = "ou=Wisc,$DomainDN"

    dsacls $sdholder /I:T /R "NT AUTHORITY\Authenticated Users"
    dsacls $sdholder /I:T /G "NT AUTHORITY\Authenticated Users:RCRP"

    dsacls $ENTOU /P:y
    dsacls $ENTOU /I:T /r "NT AUTHORITY\Authenticated Users"
    dsacls $ENTOU /I:T /r "SYSTEM"
    dsacls $ENTOU /I:T /r "Account Operators"
    dsacls $ENTOU /I:T /r "Print Operators"
    dsacls $ENTOU /I:T /G "$DomainName\Enterprise Admins:GA" 
    dsacls $ENTOU /I:T /G "$DomainName\Domain Admins:GA" 
    dsacls $ENTOU /I:T /G "Administrators:GA" 
    dsacls $ENTOU /I:S /G "Pre-Windows 2000 Compatible Access:LCRCRP"
    dsacls $ENTOU /I:T /G "ENTERPRISE DOMAIN CONTROLLERS:RP"
    
    # Set target as the NetID OU    
    dsacls $WiscOU /P:y
    dsacls $WiscOU /I:T /r "NT AUTHORITY\Authenticated Users"
    dsacls $WiscOU /I:T /G "NT AUTHORITY\Authenticated Users:RCRP"

    # Other sub OUs here.

    # Schema object ACL changes here.
    }

Function Set-dsHeuristics {
    $dSHeuristics = "CN=Directory Service,CN=Windows NT,CN=Services,cn=Configuration,$((Get-ADDomain).distinguishedName)"
    $CurrentValue = (Get-ADObject -identity $dSHeuristics -pr dSHeuristics).dSHeuristics
    $Value = "001000000"

    If ($CurrentValue){
        Write-Host $CurrentValue
        Set-ADObject "$dSHeuristics" -replace @{dsHeuristics=$Value} -PassThru
        }Else{
        Set-ADObject "$dSHeuristics" -add @{dsHeuristics=$Value} -PassThru
        }
    }

Function Set-msdsMachineAccountQuota {

    $MachineAccount = "$((Get-ADDomain).distinguishedName)"
    $CurrentValue = (Get-ADObject -identity $MachineAccount -pr ms-DS-MachineAccountQuota)."ms-DS-MachineAccountQuota"

    If ($CurrentValue -ne 0){
        Write-Host "Ms-Ds-MachineAccountQuota is Set to $CurrentValue"
        #Set-ADObject "$MachineAccount" -replace @{"Ms-Ds-MachineAccountQuota"=0} -PassThru
        }Else{
        Write-Host "Ms-Ds-MachineAccountQuota is configured correctly"
        }
    }

Function Configure-DNSServer {
    Set-DnsServerScavenging `
        -ScavengingInterval 3.00:00:00 `
        -NoRefreshInterval 3.00:00:00 `
        -RefreshInterval 3.00:00:00 `
        -ApplyOnAllZones `
        -passthru

    Set-DnsServerForwarder `
        -IPAddress 128.104.254.254,144.92.254.254 `
        -passthru

    Set-DnsServerRecursion `
        -Enable $False `
        -Passthru

    Get-DnsServerZone | ? {$_.IsAutoCreated -eq $False} | Set-DnsServerZoneAging `
        -Aging $true `
        -NoRefreshInterval 3.00:00:00 `
        -RefreshInterval 3.00:00:00 `
        -PassThru 
    }

Function Create-XMLFile {
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)

    # choose formatting:
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"

    # write the header and XSL statements
    $xmlWriter.WriteStartDocument()
    $xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")

    # create root element "machines" and add some attributes to it
    $XmlWriter.WriteComment('Active Directory Configuration')
    $XmlWriter.WriteStartElement('AD')

    # each data set is called "machine", add a random attribute to it:
    $XmlWriter.WriteComment("Domain Controller details")
    $xmlWriter.WriteStartElement('Host')
    $xmlWriter.WriteElementString('HostName',$HostName)
    $xmlWriter.WriteElementString('RenameHost',$RenameHost)
    $XmlWriter.WriteElementString('IPAddress',$IPAddress)
    $XmlWriter.WriteElementString('Interface',$SelectedInterface)
    $xmlWriter.WriteElementString('Prefix',$Prefix)
    $xmlWriter.WriteElementString('DefaultGateWay',$DefaultGateWay)
    $xmlWriter.WriteElementString('DNSSuffix',$FQDN)
    $xmlWriter.WriteElementString('DNSServer',$DNSServer)
    $xmlWriter.WriteElementString('SYSVOLDrive',$SYSVOLDrive)
    $xmlWriter.WriteElementString('NTDSDrive',$NTDSDrive)
    $xmlWriter.WriteElementString('LogsDrive',$LogsDrive)
    $xmlWriter.WriteElementString('NETLOGON',$NETLOGON)
    $xmlWriter.WriteElementString('FILEREP',$FILEREP)
    $xmlWriter.WriteElementString('AllowRDP',$AllowRDP)
    $xmlWriter.WriteElementString('SecureRDP',$SecureRDP)
    $xmlWriter.WriteEndElement()

    $XmlWriter.WriteComment("AD Forest details")
    $xmlWriter.WriteStartElement('Forest')
    $xmlWriter.WriteElementString('FQDN',$FQDN)
    $xmlWriter.WriteElementString('DomainName',$DomainName)
    $xmlWriter.WriteElementString('NewForest',$NewForest)
    $xmlWriter.WriteElementString('SafeModePassword',$SafeModePassword)
    $xmlWriter.WriteElementString('SYSVOLPath',$SYSVOLPath)
    $xmlWriter.WriteElementString('NTDSPath',$NTDSPath)
    $xmlWriter.WriteElementString('LogsPath',$LogsPath)

    $xmlWriter.WriteEndElement()

    $xmlWriter.WriteEndElement() # close the "machines" node:
    $xmlWriter.WriteEndDocument() # finalize the document:
    $xmlWriter.Flush()
    $xmlWriter.Close()
    }

Function Clear-Info {
    If ($(Read-Host "Do you wish to clear this information? (Yes/No) [Yes]") -like "Y*"){Remove-Item $Path}
    Get-Variable * -Scope Global | Remove-Variable -ea SilentlyContinue
    Show-Information
    }

Function Show-Information {
        $Global:Config = [xml](Get-Content $Path -ea SilentlyContinue)
        CLS
        "********************************************************"
        "*      Collect Information for AD DC and Forest        *"
        "*                                                      *"
        "*                                                      *"
        "********************************************************"
        "`t1 - Clear All Info"
        "`t2 - Export Config"
        ""
        "Domain Controller"
        "`t3 - Select Network Interface  " + $Config.AD.Host.Interface
        "`t4 - Host Name:                " + $Config.AD.Host.HostName
        "`t5 - IP Address:               " + $Config.AD.Host.IPAddress
        "`t6 - Prefix:                   " + $Config.AD.Host.Prefix
        "`t7 - Default Gateway:          " + $Config.AD.Host.DefaultGateWay
        "`t8 - DNS Servers               Primary DNS: " + $Config.AD.Host.IPAddress +"`t Secondary DNS: " + $Config.AD.Host.DNSServer
        "`t9 - SYSVOL Drive:             " + $Config.AD.Host.SYSVOLDrive
        "`t10 - NTDS Drive:              " + $Config.AD.Host.NTDSDrive
        "`t11 - Logs Drive:              " + $Config.AD.Host.LogsDrive
        "`t12 - NETLOGON Port:           " + $Config.AD.Host.NETLOGON
        "`t13 - DFSR Port:               " + $Config.AD.Host.FileRep
        "`t14 - Allow RDP:               " + $Config.AD.Host.AllowRDP
        "`t15 - Secure RDP:              " + $Config.AD.Host.SecureRDP
        ""
        "Active Directory"
        "`t16 - New Forest:              " + $Config.AD.Forest.NewForest
        "`t17 - DNS Domain Name:         " + $Config.AD.Forest.FQDN
        "`t18 - Dimain Name:             " + $Config.AD.Forest.DomainName
        "`t19 - NTDS Password:           " + $Config.AD.Forest.SafeModePassword
        ""
        "Configuration"
        "`t20 - Configure Host"
        "`t21 - Promote Host to DC (New Forest)"
        "`t22 - Promote Host to DC (Existing Forest)"
        "`t23 - Configure Active Directory"
        "`tQ - Quit"
        $Choice = Read-Host "`nSelect task"

        Switch ($Choice) {
            1  {Clear-Info}
            2  {}
            3  {Select-Adapter}
            4  {Get-HostName}
            5  {Get-IPAddress}
            6  {Get-IPPrefix}
            7  {Get-IPDefaultGateWay}
            8  {Get-IPDNSServers}
            9  {Get-SYSVOLDrive}
            10 {Get-NTDSDrive}
            11 {Get-LogsDrive}
            12 {Get-StaticNetlogon}
            13 {Get-StaticNTFRS}
            14 {Get-AllowRDP}
            15 {Get-SecureRDP}
            16 {Get-NewForest}
            17 {Get-DNSDomainName}
            18 {Get-DomainName}
            19 {Get-SafeModePassword}
            20 {Show-HostMenu}
            21 {Show-ADNewMenu}
            22 {Show-ADExistMenu}
            23 {Show-ADConfigMenu}
            q {Break}
            Default {Show-Information}
            }
    }

Function Show-HostMenu {
        CLS
        "********************************************************"
        "*      Collect Information for AD DC and Forest        *"
        "*                                                      *"
        "*                                                      *"
        "********************************************************"
        "`t1 - Clear All Info"
        "`t2 - Export Config"
        Configure-NetworkInterface
        Configure-Storage
        Configure-StaticPorts
        Configure-RDP
        Configure-HostName
        Show-Information
    }

Function Show-ADNewMenu {
    #Create-StoragePaths
    Install-ADDSRoles
    New-Forest2012
    Configure-DNSServer
    Restart-Computer -Force
    }

Function Show-ADExistMenu {
    # Check for Domain Join
    Create-StoragePaths
    Install-ADDSRoles
    Exist-Forest2012
    Configure-DNSServer
    Restart-Computer -Force
    }

Function Show-ADConfigMenu {
    Create-OUStructure
    Move-SensitiveObjects
    Configure-OUACLs
    Set-dsHeuristics
    Set-msdsMachineAccountQuota
    Show-Information
    }

Show-Information