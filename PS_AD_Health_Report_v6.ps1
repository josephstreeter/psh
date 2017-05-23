import-module activedirectory

Clear-Host

$date = get-date -uformat "%Y-%m-%d"
$startDate = (Get-Date).adddays(-1) #Sets the start date for Event Logs as yesterday

$Forest = Get-ADForest
$Domains = $Forest.Domains
$DCs = foreach ($Domain in $Domains) {foreach ($DC in $(Get-ADDomain $Domain).replicadirectoryservers | sort) {$DC}}
#$DCs = Get-ADDomainController

$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "joseph.streeter@wisc.edu"
$mailto = "joseph.streeter@wisc.edu"

function Get-ForestReport {
	"################## AD Forest Information ##########################"
	""
	$date
	"" 
	"Forest Name:            " + $Forest.name
	"Forest Root Domain:     " + $Forest.rootdomain
	"Forest Mode:            " + $Forest.forestmode
	"Schema Master:          " + $Forest.SchemaMaster
	"Domain Naming Master:   " + $Forest.DomainNamingMaster
	"Global Catalog Servers: "
		foreach ($GC in $Forest.GlobalCatalogs)
			{
	        "                        " + $GC
			}
	""
	"################## AD Domain Information ##########################"
	""
	foreach ($Domain in $Forest.Domains)
		{
		$Domain = Get-ADDomain $Domain
		"DNS Name:               " + $Domain.DNSRoot
		"PDC Emulator:           " + $Domain.PDCEmulator
		"NetBIOS Name:           " + $Domain.NetbiosName
		"Domain Mode:            " + $Domain.DomainMode
		"Domain SID:             " + $Domain.DomainSID
		"Infrastrucure Master:   " + $Domain.InfrastructureMaster
		"PDC Emulator:           " + $Domain.PDCEmulator
		"RID Master:             " + $Domain.RIDMaster 
		""

		"Domain Controllers:"
			$DCs = $Domain.ReplicaDirectoryServers
			foreach ($DC in $DCs)
					{
					"                        " + $DC
					}
		""
		"RODCs: "
			$RODCs = $Domain.ReadOnlyReplicaDirectoryServers
			foreach ($RODC in $RODCs)
					{
					"                        " + $RODC
					}
		""
		}
	}

Function Get-DCDiagReport($DCs) {
    "#########################"
	"DCDiag Report           "
	"#########################"
    $DCDiagReport = @()

    Write-Host "Starting DCDiag Tests"
    Foreach ($DC in $DCs) {
        "`tTesting $DC ...."
        $DCDiagResults = New-Object System.Object
        
        $DCDIAG = dcdiag /s:$DC /v #/test:Intersite /test:topology
    
        Foreach ($Entry in $DCDIAG) {
            Switch -Regex ($Entry) {
                "Starting" {$Testname = ($Entry -replace ".*Starting test: ").Trim()}
                "passed|failed" {If ($Entry -match "passed") {
                                    $TestStatus = "Passed"
                                    } Else {
                                    $TestStatus = "failed"
                                    }
                                }
                }
    
        $DCDiagResults | Add-Member -name Server -Type NoteProperty -Value $DC  -Force
            If ($TestName -ne $null -and $TestStatus -ne $null) {
                $DCDiagResults | Add-Member -Type NoteProperty -name $($TestName.Trim()) -Value $TestStatus -Force
                }
            }
        $DCDiagReport += $DCDiagResults
        }
    $DCDiagReport | ft Server,Connectivity,Advertising,FrsEvent,DFSREvent,SysVolCheck,KccEvent,KnowsOfRoleHolders,MachineAccount,NCSecDesc,NetLogons -AutoSize
    }

Function Get-ReplReport {
    "#########################"
	"Replication Report           "
	"#########################"
    Write-Host "Starting Repadmin Tests"

    $Repl = repadmin /showrepl * /csv
    $ReplResults = $Repl | ConvertFrom-Csv 

    $ReplReport = @()

    Foreach ($result in $ReplResults) {

        $ReplReport += New-object PSObject -Property @{
            "DestSite" =          $Result.'Destination DSA'
            "Dest" =              $Result.'Destination DSA Site'
            "NamingContext" =     $Result.'Naming Context'
            "SourceSite" =        $Result.'Source DSA Site'
            "Source" =            $Result.'Source DSA'
            "Transport" =         $Result.'Transport Type'
            "NumberFailures" =    $Result.'Number of Failures'
            "LastFailureTime" =   $Result.'Last Failure Time'
            "LastSuccessTime" =   $Result.'Last Success Time'
            "LastFailureStatus" = $Result.'Last Failure Status'
            }
        }

    $ReplReport | select "Source","SourceSite","Dest","DestSite","NumberFailures","LastFailureTime","LastFailureStatus","LastSuccessTime","Transport","NamingContext" | sort Source | ft -AutoSize
    }

Function Get-ServiceReport($DCs) {
    "#########################"
	"Service Report           "
	"#########################"    
    $ServiceReport = @()
    
    Foreach ($DC in $DCs) {
        $ServiceReport += New-object PSObject -Property @{
            "Host" =         $DC
            "Event System" = (Get-WmiObject -computer $DC win32_service -filter "Name='eventsystem'").status
            "RPCSS" =        (Get-WmiObject -computer $DC win32_service -filter "Name='rpcss'").status
            "NTDS" =         (Get-WmiObject -computer $DC win32_service -filter "Name='ntds'").status
            "DNSCache" =     (Get-WmiObject -computer $DC win32_service -filter "Name='Dnscache'").status
            "DNS" =          (Get-WmiObject -computer $DC win32_service -filter "Name='dns'").status
            "DFSR" =         (Get-WmiObject -computer $DC win32_service -filter "Name='dfsr'").status
            "FRS" =          (Get-WmiObject -computer $DC win32_service -filter "Name='ntfrs'").status
            "ISMServ" =      (Get-WmiObject -computer $DC win32_service -filter "Name='IsmServ'").status
            "KDC" =          (Get-WmiObject -computer $DC win32_service -filter "Name='kdc'").status
            "SAMSS" =        (Get-WmiObject -computer $DC win32_service -filter "Name='samss'").status
            "Server" =       (Get-WmiObject -computer $DC win32_service -filter "Name='lanmanserver'").status
            "Workstaton" =   (Get-WmiObject -computer $DC win32_service -filter "Name='lanmanworkstation'").status
            "Time" =         (Get-WmiObject -computer $DC win32_service -filter "Name='w32time'").status
            "NetLogon" =     (Get-WmiObject -computer $DC win32_service -filter "Name='NetLogon'").status
            }
        }
    $ServiceReport | Select Host,RPCSS,SAMSS,Time,DFSR,NetLogon,DNSCache,Workstaton,NTDS,ISMServ | ft -AutoSize
    }

Function Get-StorageReport($DCs) {
    "#########################"
	"Storage Report           "
	"#########################"
    $StorageReport = @()
    
    foreach ($DC in $DCs) {
        $Storage = (Get-WmiObject -ComputerName $DC -Class Win32_LogicalDisk) | select DeviceID,Size,Freespace	
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $DC)
        
        $key_ntds =     $reg.OpenSubKey("System\CurrentControlSet\Services\NTDS\Parameters")
	    $key_sysvol =   $reg.OpenSubKey("System\CurrentControlSet\Services\Netlogon\Parameters")
        $key_os =       $reg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")
        
        $ntds_drive =   $key_ntds.GetValue("DSA Working Directory").Split("\")[0]
        $sysvol_drive = $key_sysvol.GetValue("SysVol").Split("\")[0]
		$os_drive =     $key_os.GetValue("SystemRoot").Split("\")[0]
        
        $OS = $Storage | ? {$_.DeviceID -eq $os_drive}
        $NTDS = $Storage | ? {$_.DeviceID -eq $ntds_drive}
        $SYSVOL = $Storage | ? {$_.DeviceID -eq $sysvol_drive}

        $StorageReport += New-object PSObject -Property @{
            "Host" =        $DC
            "SystemDrive" = $OS.DeviceID
            "SystemSize" =  "{0:N2}" -f ($OS.Size / 1024 / 1024 / 1024)
            "SystemFree" =  "{0:P2}" -f ($OS.FreeSpace / $OS.Size)
            "NTDSDrive" =   $NTDS.DeviceID
            "NTDSSize" =    "{0:N2}" -f ($NTDS.Size / 1024 / 1024 / 1024)
            "NTDSFree" =    "{0:P2}" -f ($NTDS.FreeSpace / $NTDS.Size)
            "SYSVOLDrive" = $SYSVOL.DeviceID
            "SYSVOLSize" =  "{0:N2}" -f ($SYSVOL.Size / 1024 / 1024 / 1024)
            "SYSVOLFree" =  "{0:P2}" -f ($SYSVOL.FreeSpace / $SYSVOL.Size)
            #"Logs Drive" =  $Logs.DeviceID
            #"Logs Size" =   "{0:N2}" -f ($Logs.Size / 1024 / 1024 / 1024)
            #"Logs Free" =   "{0:P2}" -f ($Logs.FreeSpace / $Logs.Size)
            }
        }
    $StorageReport | ft Host,SystemDrive,SystemSize,SystemFree,SYSVOLDrive,SYSVOLSize,SYSVOLFree,NTDSDrive,NTDSSize,NTDSFree,LogsDrive,LogsSize,LogsFree -AutoSize
    }

Function Get-ResourceReport($DCs) {
    "#########################"
	"Resource Report           "
	"#########################"
    $ResourceReport = @()
    Foreach ($DC in $DCs) {
        $ResourceReport += New-object PSObject -Property @{
            "Server" =            $DC
            "Memory" =            "{0:N1}" -f ((get-wmiobject -class "Win32_ComputerSystem" -computer $DC).totalphysicalmemory/1024/1024/1024)
            "CPU" =               (get-wmiobject -class "win32_processor" -computer $DC).count
            "BIOS_Mfg" =          (get-wmiobject -class "win32_BIOS" -computer $DC).Manufacturer
            "BIOS_Version" =      (get-wmiobject -class "win32_BIOS" -computer $DC).Version
            "Mfg" =               (get-wmiobject -class "win32_ComputerSystem" -computer $DC).Manufacturer
            "Model" =             (get-wmiobject -class "win32_ComputerSystem" -computer $DC).Model
            }
        }
    $ResourceReport | ft Server,CPU,Memory,Mfg,Model,BIOS_Version,BIOS_Mfg -AutoSize
    }

function Get-SystemEvents($DCs) {
	$block = @("3221227472","3221229571","7040","7036","6013","5805","5723","5722","5719","4113","2501","2000","1500","65","64","29")
    "#########################"
	"System Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $systemEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='system';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $SystemEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Get-ApplicationEvents($DCs) {
	$block = @("8224","4113","4102","4100","4097","2006","2005","2003","2001","1704","754","753","302","301","216","300","103","102","65","64","29","7","4","0001","0000")
    "#########################"
	"Application Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $ApplicationEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='Application';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $ApplicationEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Get-SecurityEvents($DCs) {
	$block = @("0000", "0001")
    "#########################"
	"Security Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $SecurityEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='Security';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $SecurityEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Get-DNSEvents($DCs) {
	$block = @("6522","3150","2501","0000", "0001")
    "#########################"
	"DNS Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $DNSEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='DNS Server';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $DNSEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Get-DSEvents($DCs) {
	$block = @("2888","2041","2001","1535","1226","701","700")
    "#########################"
	"Directory Service Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $DSEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='Directory Service';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $DSEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Get-FRSEvents($DCs) {
	$block = @("13501")
    "#########################"
	"File Replication Service Events"
	"#########################"
    foreach ($DC in $DCs) {	
		$DC 
		"----------------------------------------"
		
        $FRSEvents = Get-WinEvent -computername $DC -FilterHashtable @{Logname='file replication service';StartTime=(Get-Date).adddays(-1)} -ErrorAction SilentlyContinue

		foreach ($Event in $FRSEvents){
			if (($block -notcontains $Event.id)) {
				$event.TimeCreated
				"Event ID:   " + $Event.id
				"Event Type: " + $Event.LevelDisplayName
				"Event Message:"
				$Event.Message
				""
			    }
			}
		}
	}

function Send-Report {
    Send-mailmessage `
        -to joseph.streeter@wisc.edu `
        -from joseph.streeter@wisc.edu `
        -subject "Active Directory Health Report $date ($Domain)" `
        -body "Health Check" `
        -Attachments $(Get-ChildItem | ? {$_.name -like "HC-$Date*"} | select -ExpandProperty name) `
        -smtpserver smtp.wiscmail.wisc.edu

    Get-ChildItem | ? {$_.name -like "HC-*"} | Remove-Item
    }

Get-ForestReport | Out-File ".\HC-$Date-01-Forest-Report.txt"
Get-ResourceReport $DCs | Out-File ".\HC-$Date-02-Resource-Report.txt"
Get-StorageReport $DCs | Out-File ".\HC-$Date-03-Storage-Report.txt"
Get-DCDiagReport $DCs | Out-File ".\HC-$Date-04-DCDiag-Report.txt"
Get-ReplReport | Out-File ".\HC-$Date-05-Replication-Report.txt"
Get-ServiceReport $DCs | Out-File ".\HC-$Date-06-Services-Report.txt"
Get-SystemEvents $DCs | Out-File ".\HC-$Date-07-System-Events-Report.txt"
Get-ApplicationEvents $DCs | Out-File ".\HC-$Date-08-App-Events-Report.txt"
#Get-SecurityEvents $DCs | Out-File ".\HC-$Date-09-Security-Events-Report.txt"
Get-DNSEvents $DCs | Out-File ".\HC-$Date-10-DNS-Events-Report.txt"
Get-DSEvents $DCs | Out-File ".\HC-$Date-11-DS-EVents-Report.txt"
Get-FRSEvents $DCs | Out-File ".\HC-$Date-12-Forest-Report.txt"
#Send-Report
