Function Get-ServiceStartName()
    {
    Param([string]$ComputerName=".")
    $Results=get-wmiobject win32_service -ComputerName $ComputerName | select name,startmode,state,startname
    return $Results
    }

Function Send-Message($subject,[string]$body)
    {
    Send-MailMessage `
        -to "jstreeter@madisoncollege.edu" `
        -From "Streeter, Joseph A <jstreeter@madisoncollege.edu>" `
        -Body $body `
        -Subject $subject `
        -SmtpServer "smtp.madisoncollege.edu" `
    }

$i=0
$Servers = Get-ADComputer -filter * -SearchBase "OU=servers,dc=matc,dc=madison,dc=login"
$Srv=@()
foreach ($Server in $Servers | sort dnshostname)
    {
    $i++
    $Server.DnsHostName + "($i of $($Servers.count))"
    $Services=Get-ServiceStartName -ComputerName $Server.DnsHostName # | Group Startname -NoElement | Sort Count
    foreach ($Service in $Services)
        { 
        $srv+=New-Object psobject -Property @{
                                            "Host"=$Server.DnsHostName
                                            "Name"=$Service.name
                                            "StartMode"=$Service.startmode
                                            "State"=$Service.state
                                            "Account"=$Service.startname
                                            }
        }
    }

$srv | ft host,name,startmode,state,account
$srv | group account -NoElement | sort count

Send-Message "Service Account Report Complete" "Script Completed"