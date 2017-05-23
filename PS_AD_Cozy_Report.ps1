
#$Cred = Get-Credential "matcmadison\jstreeter_a"

Begin
    {
    $Global:date = get-date -uformat "%Y-%m-%d"
    
    $Global:FilePath = "C:\Scripts"
    $Global:Logfile = $FilePath + "\"+$date+"-Cozy-logfile.txt"
    $Global:Rptfile = $FilePath + "\"+$date+"-Cozy-Report.txt"
    
    $OUs="OU=FacStaff,DC=MATC,DC=Madison,DC=Login","OU=Student,DC=MATC,DC=Madison,DC=Login"

    function Query-ADComputers()
        {
        $Results=@()

        foreach ($OU in $OUs)
            {    
            $Results=Get-ADComputer -Filter * -pr Comment,IPv4Address,lastlogondate -SearchBase $OU | ? {($_.lastlogondate -gt $((Get-Date).AddMonths(-1)))-and ($_.comment -eq "Unavailable")} # -and ($_.comment -ne "Success")
            Return $Results
            }
        }

    function Update-ADComputers($Computer,$Value)
        {
        if ($computer.comment)
            {
            Set-ADComputer $Computer.Name -Replace @{Comment=$Value}
            }
        Else
            {
            Set-ADComputer $Computer.Name -Add @{Comment=$Value}
            }
        }

    function Query-Events($computer,$IPv4Address)
        {
        $Args = @{
            Namespace = ‘root\subscription’
            ComputerName = $Computer.Name
            Credential = $Cred
            }
        $results=@()

        $results+=(Get-WmiObject @Args -Class ‘__EventFilter’)
        $results+=(Get-WmiObject @Args -Class ‘__EventConsumer’)
        
        if ($results) 
            {
            Log "Success" "Captured results from $($Computer.name) ($($Computer.ipv4address))"
            Update-ADComputers $COMPUTER Success
            }
        else
            {
            Log "Failure" "Unable to capture results from $($Computer.name) ($($Computer.ipv4address))!"
            Update-ADComputers $COMPUTER Failure
            }

        Return $results
        }
    
    Function Log($EntryType,$Entry)
        {
        $datetime = get-date -uformat "%Y-%m-%d-%H:%m:%S"
        if (get-item $Logfile -ea 0)
            {
            $DateTime+" - "+$EntryType+" - "+$Entry | Out-File $Logfile -Append
            }
        Else
            {
            $DateTime+" - "+$EntryType+" - "+$Entry | Out-File $Logfile
            }
        }

    function Write-Report($Results)
        {
        Log "Informational" "Creating Report File"
        try {$Results | select PSComputerName,__SUPERCLASS,Name | ConvertTo-Csv -NoTypeInformation | Out-File $Global:Rptfile}
        catch {Log "Failure" "Failed to create Report File"}
        }

    Log "Informational" "Script starting"
    }





Process
    {
    $Results=@()
    $Computers=Query-ADComputers
    
    Log "Informational" "$($Computers.count) computers to query"

    foreach ($Computer in $Computers)
        {
        if (Test-Connection $Computer.name -Count 1 -ErrorAction 0)
            {
            $Results+=Query-Events $computer $Computer.IPv4Address 
            }
        Else
            {
            Log "Informational" "$($Computer.Name) is not available - Last Logon Date: $($Computer.lastlogondate)"
            Update-ADComputers $Computer Unavailable
            }
        }
    
    Write-Report $Results
    }





End
    {
    Log "Informational" "Script ending"
    }