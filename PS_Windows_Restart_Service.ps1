
$Debug=$true # Set to true in order to recieve success email messages
$Services="SWSvc","SnapDriveService","SnapManagerService"
$To="jstreeter@madisoncollege.edu","gthuber@madisoncollege.edu"
$from="jstreeter@madisoncollege.edu"

Function Send-Email()
    {
    Param
        (
        [Parameter(Mandatory=$true)]$To,
        [Parameter(Mandatory=$true)]$Subject,
        [Parameter(Mandatory=$true)]$Body,
        [Parameter(Mandatory=$false)]$Attachment
        )
    
    $SMTPServer="smtp.madisoncollege.edu"

    Send-MailMessage `
        -to $To `
        -From $From `
        -Subject $Subject `
        -Body $Body `
        -SmtpServer $SMTPServer
    }

function Restart-SnapService()
    {
    "Restarting Service"
    try {restart-service swsvc -ea Stop -Force}  catch {}

    if ($?)
        {
        if ($Debug){Send-Email -To $To -Subject "Snap Service Restarted Successfully" -Body "Snap Service Restarted Successfully"}
        }
    else
        {
        Send-Email -To $To -Subject "Snap Service Failed to Restart" -Body "Snap Service Failed to Restart" 
        }
    }

function Check-Status($Service)
    {
    "Check $Service Status"
    Return $(Get-Service $Service)
    }

Restart-SnapService
$report=@()

foreach ($service in $Services)
    {
    $SvcStatus=Check-Status $Service
    if ($SvcStatus.status -ne "running"){Start-Service $Service -ea SilentlyContinue}
    $report+=New-Object PSObject -Property @{"Service"=$SvcStatus.DisplayName;"Status"=$SvcStatus.Status}
    }

if ($($report | ? {$_.status -ne "running"}).count -gt 0)
    {
    Send-Email -To $To -Subject "Snap Services Failed to Start" -Body "$($report | Out-String)"    
    }
else
    {
    if ($Debug){Send-Email -To $To -Subject "Snap Service Running" -Body "$($report | Out-String)"}
    }