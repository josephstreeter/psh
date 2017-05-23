# http://www.anilerduran.com/index.php/2013/how-to-parse-dcdiag-output-with-powershell/

Import-Module activedirectory
$DCs = $(Get-ADDomainController -filter *).name
$Results = New-Object System.Object
$Report = @()

Foreach ($DC in $DCs) 
    {
    $DCDIAG = dcdiag /s:$DC
    $Results | Add-Member -name Server -Value $DC -Type NoteProperty -Force
    Foreach ($Entry in $DCDIAG) 
        {
        Switch -Regex ($Entry) {
            "Starting" {$Testname = ($Entry -replace ".*Starting test: ").Trim()}
            "passed|failed" {If ($Entry -match "Passed") 
                                {
                                $TestStatus = "Passed"
                                } Else {
                                $TestStatus = "** Failed **"
                                }
                            }
            }
        If (($TestName -ne $null) -and ($TestStatus -ne $null)) 
            {
            $Results | Add-Member -Type NoteProperty -name $($TestName.Trim()) -Value $TestStatus -Force
            }
        }
    $Report += $Results
    }

$Report | select Server, NetLogons, KccEvent, Replications, Services, SystemLog, SysVolCheck | ft * -AutoSize
    
    #$Props = $report | gm -membertype noteproperty | select -ExpandProperty name
    #$Report | select $(foreach ($prop in $props) {if ($report.$prop -ne "passed"){$prop}}) | ft -AutoSize