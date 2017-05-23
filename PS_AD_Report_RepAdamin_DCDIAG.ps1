

############
# Functions 
############
Function Get-ForestDomainControllers
    {
    $Results=@()
    foreach ($domain in (Get-ADForest).domains )
        {
        $Results+=(Get-ADdomain $domain).ReplicaDirectoryServers
        }
    Return $Results
    }

Function Get-DCDiagReport($DC)
    {
    "Testing $DC"
    $DCDIAG = dcdiag /s:$DC /v #/test:Intersite /test:topology
    $DCDiagResults = New-Object System.Object
    $DCDiagResults | Add-Member -name Server -Value $DC -Type NoteProperty -Force
    
    Foreach ($Entry in $DCDIAG) 
        {
        Switch -Regex ($Entry) 
            {
            "Starting" {$Testname = ($Entry -replace ".*Starting test: ").Trim()}
            "passed|failed" {If ($Entry -match "passed") {$TestStatus = "Passed"} Else {$TestStatus = "Failed"}}
            }
            
        If ($TestName -ne $null -and $TestStatus -ne $null) 
            {
            $DCDiagResults | Add-Member -Type NoteProperty -name $($TestName.Trim()) -Value $TestStatus -Force
            }
        }
    Return $DCDiagResults
    }

Function Get-ReplReport 
    {
    "Starting Repadmin Tests"

    $Repl = repadmin /showrepl * /csv
    $ReplResults = $Repl | ConvertFrom-Csv 

    $ReplReport = @()

    Foreach ($result in $ReplResults) 
        {
        $ReplReport += New-object PSObject -Property @{
            "DestSite" = $Result.'Destination DSA Site'
            "Dest" = $Result.'Destination DSA'
            "NamingContext" = $Result.'Naming Context'
            "SourceSite" = $Result.'Source DSA Site'
            "Source" = $Result.'Source DSA'
            "Transport" = $Result.'Transport Type'
            "NumberFailures" = $Result.'Number of Failures'
            "LastFailureTime" = $Result.'Last Failure Time'
            "LastSuccessTime" = $Result.'Last Success Time'
            "LastFailureStatus" = $Result.'Last Failure Status'
            }
        }
    Return $ReplReport
    }

##############
# Gather Data 
##############

Clear-Host
Import-Module activedirectory

"Collecting Forest Domain Controllers"
$DCs=Get-ForestDomainControllers

"Starting DCDiag Tests"
$DCDiagRpt=@()
foreach ($DC in $DCs | sort)
    {
    $DCDiagRpt+=Get-DCDiagReport $DC.ToUpper()
    }

##################
# Display Results
##################

"Starting Repadmin Tests"
$ReplRrt=Get-ReplReport

"DCDiag Test Results (Page 1 of 2)"
$DCDiagRpt | ft Server,Connectivity,Advertising,DFSREvent,SysVolCheck,KccEvent,NCSecDesc,Replications,RidManager,Services,Intersite,LocatorCheck -AutoSize
"DCDiag Test Results (Page 2 of 2)"
$DCDiagRpt | ft Server,FrsEvent,KnowsOfRoleHolders,MachineAccount,NetLogons,ObjectsReplicated,SystemLog,VerifyReferences,CheckSDRefDom,CrossRefValidation -AutoSize

"Replication Test Results"
$Servers = $ReplRrt | select -ExpandProperty Source -Unique 

foreach ($Server in ($Servers | Sort))
    {
    "$Server"
    $ReplRrt | ? {$_.Source -eq $Server} | select "NamingContext","Dest","SourceSite","DestSite","NumberFailures","LastFailureTime","LastFailureStatus","LastSuccessTime","Transport" | sort NamingContext,Dest | ft -AutoSize
    }