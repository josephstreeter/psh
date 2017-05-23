$ServerStatusReport = @()
$Date = (Get-Date).AddDays(-7)

Get-Date | out-file C:\Scripts\Server_Success.log
Get-Date | out-file C:\Scripts\Server_Fail.log

Function Check-PatchComplete {
    #$(Get-Item \\$server\c$\windows\system32\dnsapi.dll -ea 0).LastWriteTime.Date -eq $(get-date 03/22/2011)
    If ((Get-Item \\$server\c$\windows\system32\dnsapi.dll -ea 0).LastWriteTime.Date -eq $(get-date 03/22/2011))
        {
        Return $true
        }
        Else
        {
        Return $false
        }
    }

Function Check-PatchInstall {
    #(Get-Item \\$server\c$\windows\winsxs\Manifests\amd64_microsoft-windows-dns-client_31bf3856ad364e35_6.1.7600.20930_none_3e222f7b503f137.manifest -ErrorAction 0) -or (Get-Item "\\$server\c$\Windows\System32\catroot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\Package_2_for_KB2520155~31bf3856ad364e35~amd64~~6.1.1.0.cat" -ea 0)
    #(Get-ChildItem -path \\$server\c$\Windows\System32\catroot -Recurse -Filter "*KB2520155*")
    if (Get-WmiObject  -ComputerName $server -Class Win32_QuickFixEngineering -Filter {HotFixID="KB2520155"})
        {
        Return $true
        }
        Else
        {
        Return $False
        }
    }

Function Check-PatchFile {
    if (Get-Item \\$server\c$\Windows6.1-KB2520155-x64.msu -ea 0)
        {
        Return $True
        }
        Else
        {
        Return $False
        }
    }

Function Copy-Patch {
    Copy-Item c:\scripts\Windows6.1-KB2520155-x64.msu \\$server\c$\
    }

Function Install-Patch {
    Invoke-Command -ComputerName $server -ScriptBlock {wusa c:\Windows6.1-KB2520155-x64.msu /extract:C:\update ; dism /online /norestart /add-package /packagepath:c:\update\Windows6.1-KB2520155-x64.cab}
    }


$servers = Get-ADComputer -f '(operatingsystem -like "*2008*") -and (name -ne "ezproxy")' -pr operatingsystem,lastlogondate,IPv4Address,comment -searchbase "ou=servers,dc=matc,dc=madison,dc=login" | ? {$_.lastlogondate -gt $Date} | sort name | select -ExpandProperty name 
#$Servers = @("WDRLDEV","AGPMSERVER","DELLPSM","MCEPO","NSM","ts01","zoomtext","archman")

Foreach ($Server in $servers) 
    {
    $Server
    "____________________________"
    If (Check-PatchComplete -eq $true)
        {
        $Status = "Patch Completed"
        }
        Else
        {        
        if (Check-PatchInstall -eq $true)
            {
            $Status = "Pending Reboot"
            }
            Else
            {
            If (Check-PatchFile -eq $true)
                {
                $Status = "Pending Install"
                Install-Patch
                }
                Else
                {
                $Status = "Pending Patch file Copying"
                Copy-Patch
                Install-Patch
                }        
            }
        }

    $ServerStatus = New-Object -TypeName System.Object
    $ServerStatus | Add-Member -MemberType NoteProperty -Name ServerName -Value $Server
    $ServerStatus | Add-Member -MemberType NoteProperty -Name ServerStatus -Value $Status
    $ServerStatusReport += $ServerStatus
    }


$report = "C:\Scripts\patch-report.txt"
Get-Date | Out-File $report
$ServerStatusReport | ft -AutoSize | Out-File -Append $report


Send-MailMessage `
    -to jstreeter@madisoncollege.edu `
    -from jstreeter@madisoncollege.edu `
    -Subject "KB2520155 Install Status Report" `
    -Attachments $report `
    -smtp "smtp.madisoncollege.edu"