Param
    (
    [Parameter(Mandatory=$true)]$Service
    )

$date = get-date -uformat "%Y-%m-%d"

Function Log($EntryType,$Entry)
    {
    $FilePath = "C:\Scripts"
    
    $datetime = get-date -uformat "%Y-%m-%d-%H:%M:%S"
    $Logfile = $FilePath + "\"+$date+"-logfile.txt"
    
    if (get-item $Logfile -ea 0)
        {
        $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile -Append
        }
    Else
        {
        $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile
        }
    }

function Send-Email($subject,$body,$report)
    {
    Send-MailMessage `
        -From jstreeter@madisoncollge.edu `
        -To jstreeter@madisoncollege.edu `
        -Subject $subject `
        -SmtpServer smtp.madisoncollege.edu `
        -Body $body #`
        #-Attachments $report
    }

function List-Dependencies
    {
    [CmdLetBinding()]
    Param
        (
        $servicename,
        $level = 0,
        [switch]$infoonly
        )
    try{
        Write-Verbose $($("`t" * $level)+$servicename)
        $servicename
        $services=get-service $servicename -ea stop | where{$_.dependentservices} | select -expand dependentservices
        if($services)
            {
            $services | ? {$_.Status -eq "running"} | % {Get-Depends $($_.Name) ($level+1)}
            }
        }
    catch
        {
        $_
        }
    }

function Manage-Services($Task,$Services)
    {
    "Preparing to $Task the following services: $Services"
    foreach ($svc in $Services|Select -Unique)
        {
        try 
            {
            if ($Task -eq "Stop")
                {
                $Svc
                Stop-Service $Svc -Force -Verbose -ea Stop
                }
            Elseif ($Task -eq "Start")
                {
                $Svc
                Start-Service $Svc -Verbose
                }
            }
        catch 
            {
            Send-Email "$env:COMPUTERNAME - $Svc failed to $Task" $($_|out-string)}
            log FAILURE "$env:COMPUTERNAME - $Svc failed to $Task"
            }
        }

function Get-ServiceStatus($Services)
    {
    $Status=Get-Service $Services

    if ($Status.status -contains "Stopped")
        {
        Send-Email "$env:COMPUTERNAME - $Service not running" $($Status|out-string)
        log FAILURE "$env:COMPUTERNAME - $Service not running"
        Return $False
        }
    Else
        {
        Return $true
        }
    }

log INFO "$env:COMPUTERNAME - $Service Service Restart Begining"

$Services=List-Dependencies -v -servicename $Service

Manage-Services Stop $Services

sleep -Seconds 5 -Verbose

<#
Manage-Services Start $Services

sleep -Seconds 5 -Verbose

if (Get-ServiceStatus $Services)
    {
    log SUCCESS "$env:COMPUTERNAME - $Service and dependencies running"
    }
Else
    {
    log FAILURE "$env:COMPUTERNAME - $Service and dependencies are not running"
    }
#>