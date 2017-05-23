$PrintServer = "PSFS01.MATC.Madison.Login"

$Printers = get-printer -ComputerName $PrintServer #| select -First 10

foreach ($Printer in $Printers)
    {
    If ($printer.PortName -like "*MATC.Madison.Login")
        {
        $IP = (Resolve-DnsName $Printer.PortName -ea SilentlyContinue).IPAddress
        If ($IP)
            {      
            If (-not (Get-PrinterPort -ComputerName $PrintServer -Name $IP -ea SilentlyContinue))
                {
                Add-PrinterPort -ComputerName $PrintServer -Name $IP -PrinterHostAddress $IP
                }
            Set-Printer -ComputerName $PrintServer -Name $Printer.name -PortName $IP -PassThru
            }
        }
    }