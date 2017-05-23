
$ListOnly=$true
$ModulePath="\\adrapserver.matc.madison.login\scripts\PSWindowsUpdate"
$Module="PSWindowsUpdate"
$SMTPServer="smtp.madisoncollege.edu"
$File="C:\Windows-Update.txt"

function Map-Drive()
    {
    Param
        (
        [Parameter(Mandatory=$true)]$ModulePath
        )
    if ($Exists=Get-PSDrive | ? {$_.Root -eq $ModulePath})
            {
            Return $Exists.Name
            Break
            }

    $Drives="M","N","O","P","Q","R"."S","T"
    foreach ($Drive in $Drives)
        {
        $Used=Get-PSDrive | ? {$_.Name -eq $Drive}
        if (-not($Used))
            {
            New-PSDrive -Name $Drive -PSProvider FileSystem -Root $ModulePath -Scope Global -Persist -Credential $args[0] -Verbose| Out-Null
            Return $Drive
            Break
            }
        }
    }

function unmap-drive()
    {
    Param
        (
        [Parameter(Mandatory=$true)]$Drive
        )
    Remove-PSDrive $Drive
    }

function Load-Module()
    {
    Param
        (
        [Parameter(Mandatory=$true)]$Drive,
        [Parameter(Mandatory=$true)]$Module
        )

    if (Get-Module $($Module))
        {
        "$Module Module Loaded"
        }
    Else
        {
        $ExPolicy=Get-ExecutionPolicy
        Set-ExecutionPolicy ByPass
        Import-Module "$($Drive):\$($Module).psd1"
        Set-ExecutionPolicy $ExPolicy
        }
    }

function List-Updates()
    {
    Param
        (
        [Parameter(Mandatory=$false)]$ListOnly
        )
    $Updates=Get-WUInstall -ListOnly Software
    if ($updates)
        {
        $Updates | Out-File $File
        }
    Else
        {
        "No updates found" | Out-File $File
        }

    # Send Message
    try {Send-Email -Attachment $File -to jstreeter@madisoncollege.edu -Subject "$env:COMPUTERNAME Update Status" -Body "Update Report"}
    catch {Break}
    }

function Install-Updates()
    {
    Get-WUInstall -Confirm:$false -AcceptAll Software -AutoReboot
    }

Function Send-Email()
    {
    Param
        (
        [Parameter(Mandatory=$true)]$To,
        [Parameter(Mandatory=$true)]$Subject,
        [Parameter(Mandatory=$true)]$Body,
        [Parameter(Mandatory=$true)]$Attachment
        )

    if ($Attachment)
        {
        Send-MailMessage `
            -to $To `
            -From jstreeter@madisoncollege.edu `
            -Subject $Subject `
            -Body $Body `
            -Attachments $Attachment `
            -SmtpServer $SMTPServer
        }
    Else
        {
        Send-MailMessage `
            -to $To `
            -From jstreeter@madisoncollege.edu `
            -Subject $Subject `
            -Body $Body `
            -SmtpServer $SMTPServer
        }

    Remove-Item $Attachment
    }

##############################################################

# Load PowerShell Modules
try {$Drive=Map-Drive -ModulePath $ModulePath}
catch {Break}

try {Load-Module -Drive $Drive -Module $Module}
catch {Break}

# Check for Updates
try {List-Updates -ListOnly $true}
catch {Break}

# Install Updates
if ($ListOnly -eq $False)
        {
        Install-Updates
        }

# Cleanup Mapped Drives
try {Unmap-Drive -Drive $Drive}
catch {Break}