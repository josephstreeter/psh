CLS
$Path = "C:\Program Files\Microsoft Baseline Security Analyzer 2\"
$DCs = "TXDC1.matc.madison.login" #(Get-ADDomainController -filter *).hostname
$PropArray = @()


Function Scan-Hosts
    {
    Foreach ($DC in $DCs) 
        {
            $DC
            "Add Firewall Rule to $DC"
            Invoke-Command `
                -Computer $DC `
                -ScriptBlock {netsh advfirewall firewall add rule name="Temp MBSA Scan" dir=in localport=any remoteip=10.122.76.41 protocol=TCP action=allow} `
                -UseSSL

            "Running MBSA Scan on $DC"
            $Results = Invoke-Command {cmd $Path\mbsacli.exe /target MATCMadison\$DC /n IIS+Password+SQL+OS} -ErrorAction SilentlyContinue

            "Remove Firewall Rule from $DC"
            Invoke-Command `
                -Computer $DC `
                -ScriptBlock {netsh advfirewall firewall delete rule name="Temp MBSA Scan" dir=in localport=any remoteip=10.122.76.41 protocol=TCP} `
                -UseSSL
        }
    }

Function Create-Report
    {
    CD C:\Users\jstreeter_a\SecurityScans
    $Reports = Get-ChildItem | ? {$_.name -like "*.mbsa"}
    $CheckArray = @()

    Foreach ($Report in $Reports) 
        {
        ""
        $XML = [XML] (Get-Content $report.name)
        "Server " + $xml.SecScan.Machine
        "Domain " + $xml.SecScan.Domain
        "IP     " + $xml.SecScan.IP
        "Date   " + $xml.SecScan.LDate
        "Grade  " + $xml.SecScan.Grade
        "WSUS   " + $xml.SecScan.SUSServer
        for ($i = 0; $i -lt ($xml.SecScan.Check).count; $i++)
            {
            $xml.SecScan.Check[$i].name + " - " + $xml.SecScan.Check[$i].advice
            for ($j = 0; $j -lt ($xml.SecScan.Check[$i].detail.UpdateData).count; $j++)
                {
                $Check = New-Object System.Object
                $Check | Add-Member -type NoteProperty -name Host -value $xml.SecScan.Machine
                $Check | Add-Member -type NoteProperty -name ID -value $xml.SecScan.Check[$i].detail.UpdateData.ID[$j]
                $Check | Add-Member -type NoteProperty -name KB -value $xml.SecScan.Check[$i].detail.UpdateData.KBID[$j]
                $Check | Add-Member -type NoteProperty -name Sev -value $xml.SecScan.Check[$i].detail.UpdateData.Severity[$j]
                $Check | Add-Member -type NoteProperty -name Approved -value $xml.SecScan.Check[$i].detail.UpdateData.WUSApproved[$j]
                $Check | Add-Member -type NoteProperty -name Installed -value $xml.SecScan.Check[$i].detail.UpdateData.isInstalled[$j]
                $Check | Add-Member -type NoteProperty -name Title -value $xml.SecScan.Check[$i].detail.UpdateData.Title[$j]
                $CheckArray += $Check    
                }
            
            }
       }
    $CheckArray | ? {($_.Installed -eq "false") -and ($_.Approved -eq "true")} | sort host,ID | ft Host,ID,KB,Sev,Installed,Approved,Title -AutoSize
    $CheckArray | ? {$_.Approved -eq "false"} | sort host,ID | ft Host,ID,KB,Sev,Installed,Approved,Title -AutoSize
    }

#Create-Report
Scan-Hosts