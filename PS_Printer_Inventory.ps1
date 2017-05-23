$PrintServers = (Get-ADObject -f 'objectClass -eq "printqueue"' -pr servername) | group servername | select name

$PrinterReport = @()

foreach ($PrintServer in $PrintServers)
    {
    $Printers = gwmi -ComputerName $PrintServer.name -Class win32_printer
        
    foreach ($Printer in $Printers)
        {
        $PrintServer.Name + " " + $Printer.Name
        "_____________________________________________"
        $Queue = New-Object -Type System.Object
        $Queue | Add-Member -MemberType NoteProperty -name Name -Value $Printer.Name
        $Queue | Add-Member -MemberType NoteProperty -name PrintServer -Value $PrintServer.Name
        $Queue | Add-Member -MemberType NoteProperty -name ShareName -Value $Printer.Sharename
        $Queue | Add-Member -MemberType NoteProperty -name Comment -Value $Printer.Comment
        $Queue | Add-Member -MemberType NoteProperty -name PortName -Value $Printer.PortName
        $Queue | Add-Member -MemberType NoteProperty -name IPAddress -Value $(If ($Printer.PortName -match "10.{1,3}.{1,3}.{1,3}"){$Printer.PortName}Else{If ($Resolve = Resolve-DnsName $printer.portname -ea silentlycontinue){$Resolve.ipaddress}Else{"Failed"}})
        $Queue | Add-Member -MemberType NoteProperty -name Alive -Value $(If (Test-Connection $Printer.PortName -ErrorAction SilentlyContinue){$True}Else{$False})
        $Queue | Add-Member -MemberType NoteProperty -name DriverName -Value $Printer.DriverName
        $Queue | Add-Member -MemberType NoteProperty -name Status -Value $Printer.Status
        $Queue | Add-Member -MemberType NoteProperty -name PrinterState -Value $Printer.PrinterState
        $Queue | Add-Member -MemberType NoteProperty -name PrinterStatus -Value $Printer.PrinterStatus
        $Queue | Add-Member -MemberType NoteProperty -name Published -Value $Printer.Published
        $PrinterReport += $Queue
        }
    }

"`nAll printers"
"_______________________________"
$PrinterReport | ft ShareName,Comment,PrintServer,PortName,IPAddress,Alive,Status,PrinterStatus,PrinterState -AutoSize 

"`nPort Name DNS resolution failed"
"_______________________________"
$PrinterReport | ? {$_.IPAddress -eq "Failed"} | ft ShareName,Comment,PrintServer,PortName,IPAddress,Alive,Status,PrinterStatus,PrinterState -AutoSize 

"`nPort Name not set to IP Address"
"_______________________________"
$PrinterReport | ? {$_.PortName -notmatch "10.{1,3}.{1,3}.{1,3}"} | ft ShareName,Comment,PrintServer,PortName,IPAddress,Alive,Status,PrinterStatus,PrinterState -AutoSize 

"`nPrinter does not appear to be connected to the network"
"_______________________________"
$PrinterReport | ? {$_.Alive -eq $False} | ft ShareName,Comment,PrintServer,PortName,IPAddress,Alive,Status,PrinterStatus,PrinterState -AutoSize