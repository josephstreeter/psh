Try {
	$computers=Get-EventLog -LogName "Directory Service" -ComputerName Pulsar, Magnetar, Quasar, cadsdc-cssc-01, cadsdc-cssc-02, cadsdc-cssc-03, cadsdc-warf-01, cadsdc-warf-02, cadsdc-warf-03 -After $((get-date).adddays(-7)) | `
	 ? {$_.eventID -eq 2889} | % {$_.replacementstrings[1].replace("AD\","").replace("$","")} | group | select name
	}
Catch {
	"Failed to collect log info - " + $Error
	Break
	}
	
Try {
	$list=foreach ($computer in $computers) {$a=$computer.name;Get-ADObject -Filter {name -eq $a} -pr ObjectCategory, OperatingSystem, OperatingSystemVersion | `
	select Name, ObjectClass, OperatingSystem, OperatingSystemVersion}
	$list | sort objectclass, name, operatingsystem, operatingsystemversion | ft -auto
	}
Catch {
	"Failed to enumerate objects - " + $Error
	Break
	}


#Get-EventLog -LogName "Directory Service" -ComputerName Pulsar, Magnetar, Quasar -After $((get-date).adddays(-1)) | ? {$_.eventID -eq 2889} | % {$_.replacementstrings[1].replace("$","")}
#Get-EventLog -LogName "Directory Service" -ComputerName Pulsar, Magnetar, Quasar -After $((get-date).adddays(-1)) | ? {$_.eventID -eq 2889} | % {$_.replacementstrings[0].split(":")[1]}