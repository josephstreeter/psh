$Path = "C:\Program Files\Microsoft Baseline Security Analyzer 2\"
$DCs = "TXDC1.matc.madison.login" #(Get-ADDomainController -filter *).hostname
$PropArray = @()
CD C:\Scripts 

Function Scan-Hosts
    {
    Foreach ($DC in $DCs) 
        {
        $DC
        "Create firewall rule"   
        Invoke-Command `
            -Computer $DC `
            -ScriptBlock {netsh advfirewall firewall add rule name="Temp MBSA Scan" dir=in localport=any remoteip=10.122.76.41 protocol=TCP action=allow} `
            -UseSSL
        
        "Scan Host"
        $Results = Invoke-Command {cmd $Path\mbsacli.exe /target MATCMadison\$DC /n IIS+Password+SQL+OS} -ErrorAction SilentlyContinue
        
        "Remove firewall rule"
        Invoke-Command `
            -Computer $DC `
            -ScriptBlock {netsh advfirewall firewall delete rule name="Temp MBSA Scan" dir=in localport=any remoteip=10.122.76.41 protocol=TCP} `
            -UseSSL
        
        Create-Report($Results)
        }
    }

Function Create-Report($Results)
    {
    $items = Get-Content C:\Scripts\mbsa_rpt.txt
    $DC = "Host"

    foreach ($item in $Results) 
        {
        $Prop = New-Object System.Object
        if (($item -like "*| Missing |*") -or ($item -like "*| Not Approved |*")) 
            {
            $Prop | Add-Member -type NoteProperty -name Server     -value $DC
            $Prop | Add-Member -type NoteProperty -name Patch      -value $item.split("|").trim()[1]
            $Prop | Add-Member -type NoteProperty -name Patch_Name -value $item.split("|").trim()[3]
            $Prop | Add-Member -type NoteProperty -name Status     -value $item.split("|").trim()[2]
            $Prop | Add-Member -type NoteProperty -name Severity   -value $item.split("|").trim()[4]
            $PropArray += $Prop
            }
        }
    $PropArray | sort Server,Status,Severity | ft -AutoSize
    }

Function Display-Report
    {
    $PropArray | sort Server,Status,Severity | ft -AutoSize
    }

Scan-Hosts