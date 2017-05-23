<#$Scopes = netsh dhcp server 10.39.0.119 show scope
$LeaseReport = @()
foreach ($Scope in $Scopes)
    {
    $Leases = (netsh dhcp server 10.39.0.119 scope $Scope.split("-")[0].trim() show clients 1) | Select-String "-D-" 
    
    foreach ($Lease in $Leases) 
        {
        If ($Lease -notmatch "NEVER EXPIRES")
            {
            $Info = New-Object -type System.Object
            $Hostname = $Lease.tostring().replace("-D-",";").Split(";").Trim()
            $Info | Add-Member -MemberType NoteProperty -name Hostname -Value $Hostname[1]
            $IP = $Hostname[0].replace(" - ",";").Split(";") 
            $Info | Add-Member -MemberType NoteProperty -name IPAddress -Value $IP[0]
            $Info | Add-Member -MemberType NoteProperty -name SubnetMask -Value $IP[1]
            $Info | Add-Member -MemberType NoteProperty -name MACAddress -Value $IP[2].replace(" -",";").Split(";")[0].Trim()
            $LeaseReport += $Info
            $Info | ft -AutoSize
            }
        }

    }
$LeaseReport
#>

$PrintServer = "PSTXLAB01.MATC.Madison.Login"

$Printers = get-printer -ComputerName $PrintServer #| select -First 10

foreach ($Printer in $Printers)
    {
    If ($printer.PortName -like "*MATC.Madison.Login")
        {
        $IP = ($LeaseReport | ? {$_.HostName -eq $printer.PortName})
        If ($IP)
            {         
            If (-not (Get-PrinterPort -ComputerName $PrintServer -Name $IP.ipaddress -ea SilentlyContinue))
                {
                Add-PrinterPort -ComputerName $PrintServer -Name $IP.ipaddress -PrinterHostAddress $IP.ipaddress
                }
            Set-Printer -ComputerName $PrintServer -Name $Printer.name -PortName $IP.ipaddress -PassThru
            }
        }
    }