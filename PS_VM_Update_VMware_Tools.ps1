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
    
$VMs = "MCDC2","Directory","Directorytst01","idmdbtst01","idmsyntst01","idmsvctst01","idmdctst01","idmdctst02","TestMDC01","TestMDC02","TestMDC03","TestMDC04"
$ToolVersion=@()

Setup-Environment

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
$ToolVersion

foreach ($Ver in $ToolVersion)
    { 
    if ($Ver.ToolsVersion -lt $HighVersion)
        {
        Write-Host "$($Ver.name) Tool Version $($Ver.ToolsVersion). Updating.... "
        Update-VMTools $Ver.name
        }
    else
        {
        Write-Host "$($Ver.name) Tool version up to date."
        }
    }