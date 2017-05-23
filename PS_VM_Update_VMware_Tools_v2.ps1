#Connect to vcenter server  

function Setup-Environment()
    {
    Get-PSSnapin -Registered | ? {$_.name -match "VMWare"} | % {Add-PSSnapin $_.name}
    try {connect-viserver vctx01.madisoncollege.edu -Credential $(Get-Credential MATCMadison\jstreeter_a)}
    catch {Break}
    }

function Get-ToolsVersion($VM)
    {
    $Results=get-view -viobject $VM | select Name, @{ Name="ToolsVersion"; Expression={$_.config.tools.toolsversion}}
    Return $Results
    }

function Update-VMTools($VMName)
    {
    $VMName
    Get-VM $VMName | Update-Tools –NoReboot  
    }

function send-mail
    {  
    $emailFrom = "jstreeter@madisoncollege.edu"  
    $emailTo = "jstreeter@madisoncollege.edu"  
    $subject = "VMware Tools Updated"  
    $smtpServer = "smtp.madisoncollege.edu"  
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)  
    $smtp.Send($emailFrom, $emailTo, $subject, $Report)  
    }

function List-VMguests($action)
    {
    if ($action -eq "add")
        {
        Return Read-Host "Enter guest name to add"
        
        }
    Elseif ($action -eq "Remove")
        {
        Return Read-Host "Enter guest name to remove"
        
        }
    Get-Menu "Select"
    }

function Get-Menu($menu)
    {
    cls
    if (!($menu))
        {
        "1 - Connect to VMware vCenter"
        "2 - Select VMware guests"
        "3 - Get VMware tool versions"
        "4 - Update VMware tools"
        "q - Quit"
        $a=Read-Host "Enter selection"
        switch ($a)
            {
            1 {Setup-Environment}
            2 {Get-Menu Select}
            3 {Get-ToolsVersion}
            4 {Update-VMTools}
            "q" {break}
            default {"Invalid Choice";Get-Menu}
            }
        }
    Elseif ($menu -eq "Select")
        {
        "1 - Enter Names"
        "2 - Provide text file"
        "3 - Query Active Directory"
        "4 - Query vCenter"
        "b - Main Menu"
        "q - Quit"
        $a=Read-Host "Enter selection"
        switch ($a)
            {
            1 {Enter-VMguests}
            2 {$VMs=Import-VMguests}
            3 {$VMs=Query-ADVMguests}
            4 {$VMs=Query-VMVMguests}
            "b" {Get-Menu}
            "q" {Break}
            default {"Invalid Choice";Get-Menu}
            }
        }
        

    }

Get-Menu


<#
$VMs = "MCDC2","Directory","Directorytst01","idmdbtst01","idmsyntst01","idmsvctst01","idmdctst01","idmdctst02","TestMDC01","TestMDC02","TestMDC03","TestMDC04"
$ToolVersion=@()

foreach ($VM in $VMs)
    {
    $ToolVersion += Get-ToolsVersion $VM    
    }  

$HighVersion = $ToolVersion.toolsversion | sort -Descending | select -First 1
$LowVersion=$ToolVersion.toolsversion | sort -Descending | select -Last 1

"##############################################"
"Highest Version: " + $($ToolVersion.toolsversion | sort -Descending | select -First 1)
"Lowest Version:  " + $($ToolVersion.toolsversion | sort -Descending | select -Last 1)
"##############################################"
"`nInstalled Tool Versions:"
$ToolVersion | ft -auto

<#
foreach ($Ver in $ToolVersion)
    { 
        "Updating.... "
        Update-VMTools $Ver.name
    }
#>