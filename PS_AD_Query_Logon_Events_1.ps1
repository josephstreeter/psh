           
$DCs=(Get-ADDomainController -filter *).hostname

# Clear out the local job queue            
Get-Job | Remove-Job            
            
# Load up the local job queue with event log queries to each DC            
Write-Verbose "Querying lockout events on DCs [$DCs]."            
foreach ($DC in $DCs)
    {
    Invoke-Command -FilePath C:\Scripts\PS_AD_Query_Logon_Events.ps1 -ComputerName $DC -UseSSL -AsJob | Out-Null       
    }

do
    { 
    CLS
    "`nJobs still Running"
    Get-Job -State Running
    "`nJobs Failed"
    Get-Job -State Failed
    "`nJobs Completed"
    Get-Job -State Completed
    Start-Sleep -s 10
    }
while ((get-job -State running).count -gt 0)


foreach ($DC in $DCs)
    {
    Invoke-Command -ScriptBlock {Try {gc c:\psoft-logon.csv} catch {}} -ComputerName $DC -UseSSL
    }