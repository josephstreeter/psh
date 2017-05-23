$PrintServer = "PSFS01.MATC.Madison.Login"

$Printers = get-printer -ComputerName $PrintServer #| select -First 10

foreach ($Printer in $Printers)
    {
    If ($printer.PortName -like "*MATC.Madison.Login")
        {
        $IP = (gc C:\Scripts\printerleases.txt | Select-String $printer.PortName)
        $printer.PortName + " " + $IP
        If ($IP)
            {      
            $printer.PortName + " " + $IP    
            <#If (-not (Get-PrinterPort -ComputerName $PrintServer -Name $IP -ea SilentlyContinue))
                {
                Add-PrinterPort -ComputerName $PrintServer -Name $IP -PrinterHostAddress $IP
                }
            Set-Printer -ComputerName $PrintServer -Name $Printer.name -PortName $IP -PassThru#>
            }
        }
    }