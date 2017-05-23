$PrintServers = (Get-ADObject -f 'objectClass -eq "printqueue"' -pr servername) | group servername | select name
$PrinterReport = @()
foreach ($PrintServer in $PrintServers)
    {
    Get-Printer -ComputerName $PrintServer.name | select printerstatus, name, computername
    foreach ($Printer in $Printers)
        {
        $Printer
        $Prt = New-Object -TypeName System.Object
        $prt | Add-Member -MemberType NoteProperty -name Status -Value $Printer.Printerstatus
        $prt | Add-Member -MemberType NoteProperty -name Name -Value $Printer.Name
        $prt | Add-Member -MemberType NoteProperty -name Server -Value $Printer.ComputerName
        $PrinterReport += $Prt
        }
    }

$PrinterReport | group PrinterStatus | ft Count,Name -AutoSize