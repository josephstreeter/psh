# @author: Fabien Duchene
# @mail: fabien.duchene1 **at** googlemail.com

############ q
# PARAMETERS
############
$params_ComputerName = "." # "." is the current computer
$params_delayBetweenExecs = 60 #delay between each execution, in seconds
$params_numOfExecs = 0 #Number of executions 0 for infinite
$params_runProfilesOrder =
    @(
        
        #<# Normal Sync
        @{name="MIMMA";profilesToRun=@("DI";"DS";"EX";"DI");};
        @{name="SQLMA-Stage";profilesToRun=@("FI";"FS";"EX";"FI");};
        @{name="ADMA-Main";profilesToRun=@("DI";"DS";"Ex";"DI");};
        @{name="ADMA-DMZ";profilesToRun=@("DI";"DS";"Ex";"DI");};
        #>
        
        <#  SR Change Sync
        @{name="MIMMA";profilesToRun=@("FI";"FS";"EX";"DI");};
        @{name="SQLMA-Stage";profilesToRun=@("FI";"FS";"EX";"FI");};
        @{name="ADMA-Main";profilesToRun=@("FI";"FS";"Ex";"DI");};
        @{name="ADMA-DMZ";profilesToRun=@("FI";"FS";"Ex";"DI");};
        #>

        <# SR Change Sync - No Export
        @{name="MIMMA";profilesToRun=@("FI";"FS");};
        @{name="SQLMA-Stage";profilesToRun=@("FS";"FI");};
        @{name="ADMA-Test";profilesToRun=@("FS";"FI");};
        #>
        
        #@{type="SQL Server";profilesToRun=@("FI";"FS");};
        #@{type="Forefront Identity Management (FIM)";profilesToRun=@("FI";"FS";"EX");};
        #@{type="Active Directory";profilesToRun=@("FI";"FS";"Ex");};
        #@{type="Active Directory Application Mode (ADAM)";profilesToRun=@("FI";"FS";"EX");};
        #@{type="Forefront Identity Management (FIM)";profilesToRun=@("DI";"DS";"EX");};
        #@{type="Active Directory";profilesToRun=@("DI";"DS";"Ex");};

        <#
        @{name="MIMMA";profilesToRun=@("DI";"FS");};
        @{name="SQLMA-Stage";profilesToRun=@("FS");};
        @{name="ADMA-Test";profilesToRun=@("FS";);};
        #>

        
    );

############
# FUNCTIONS
############
$line = "-----------------------------"
function Write-Output-Banner([string]$msg) 
    {
    Write-Output $line,("- "+$msg),$line
    }


############
# DATAS
############

$MAs = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $params_ComputerName)
$numOfExecDone = 0


############
# PROGRAM
############
do {
    Write-Output-Banner("Execution #:"+(++$numOfExecDone))
    foreach($MATypeNRun in $params_runProfilesOrder) 
        {
        $found = $false;
        foreach($MA in $MAS) 
            {
            if(!$found) 
                {
                if($MA.Name.Equals($MATypeNRun.name)) 
                    {
                    $found=$true; Write-Output-Banner("MA: "+$MA.Name)
                    foreach($profileName in $MATypeNRun.profilesToRun) 
                        {
                        Write-Output (" "+$profileName)," -> starting"
                        $datetimeBefore = Get-Date;$result = $MA.Execute($profileName);$datetimeAfter = Get-Date;$duration = $datetimeAfter - $datetimeBefore;
                        if("success".Equals($result.ReturnValue))
                            {
                            $msg = "done. Duration: "+$duration.Hours+":"+$duration.Minutes+":"+$duration.Seconds
                            } 
                            else 
                            { 
                            $msg = "Error: "+$result 
                            }

                        Write-Output (" -> "+$msg)
                        }
                    }
                }
            }
    if(!$found) { Write-Output ("Not found MA type :"+$MATypeNRun.type); }
    }

    $continue = ($params_numOfExecs -EQ 0) -OR ($numOfExecDone -lt $params_numOfExecs)
    if($continue) 
        {
        Write-Output-Banner("Sleeping "+$params_delayBetweenExecs+" seconds")
        Start-Sleep -s $params_delayBetweenExecs
        }
    } while($continue) 