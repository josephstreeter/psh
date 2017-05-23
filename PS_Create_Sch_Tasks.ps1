$TaskName="!Windows-Update"
$Servers="adrapserver.matc.madison.login","PRTGPRONW02.matc.madison.login"#,"PRTGPRONW03.matc.madison.login"
$Password = "ServerTeam2017_!" #Read-Host "Enter Password"

Function Create-SchedTask($Server)
    {
    if (-not(Get-ScheduledTask -CimSession $Server -TaskName $TaskName -ea SilentlyContinue))
        {
        $action = New-ScheduledTaskAction `
                    -Execute 'Powershell.exe' `
                    -Argument '-ExecutionPolicy Bypass -NonInteractive -NoLogo -NoProfile -File \\adrapserver\scripts\send-message.ps1' `
                    -WorkingDirectory C:\ `
                    -CimSession $Server

        <#
        $trigger =  New-ScheduledTaskTrigger `
                        -Daily `
                        -At 9am
        

        $Principal = New-ScheduledTaskPrincipal `
                        -LogonType password `
                        -UserId "MATCMADISON\svc-serverupdate-ts" `
                        -RunLevel Highest `
                        -CimSession $Server
        #>
        
        Register-ScheduledTask `
            -Action $action `
            -TaskName $TaskName `
            -Description $TaskName `
            -CimSession $Server `
            -User "MATCMADISON\svc-serverupdate-ts" `
            -Password $Password `
            -RunLevel Highest 
            #-Trigger $trigger `
        }
    }

Function Start-SchedTask($Server)
    {
    start-ScheduledTask -CimSession $Server -TaskName $TaskName
    }
    
Function Unregister-SchedTask($Server)
    {
    unregister-ScheduledTask -CimSession $Server -TaskName $TaskName -Confirm:$false -PassThru
    }

Write-Host "       Creating Tasks       " -ForegroundColor Green -BackgroundColor Black
foreach ($Server in $Servers)
    {
    Unregister-SchedTask $Server
    }

Write-Host "       Removing Tasks       " -ForegroundColor Red -BackgroundColor Gray
foreach ($Server in $Servers)
    {
    Create-SchedTask $Server
    }

Write-Host "       Starting Tasks       " -ForegroundColor Green -BackgroundColor Blue
foreach ($Server in $Servers)
    {
    Start-SchedTask $Server
    }