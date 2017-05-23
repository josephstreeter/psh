$PrintServers = (Get-ADObject -f 'objectClass -eq "printqueue"' -pr servername) | group servername | select name

$PrintRpt = @()

foreach ($PrintServer in $PrintServers)
    {
    $Printers = gwmi -ComputerName $PrintServer.name win32_printer #| ? {$_.name -match "TA148"} 
    foreach ($Printer in $Printers)
        {
        $print = New-Object -TypeName System.Object
        $print | add-member -MemberType NoteProperty -name PrintServer -value $PrintServer.name
        $print | add-member -MemberType NoteProperty -name PrinterName -value $Printer.name
        $print | add-member -MemberType NoteProperty -name PrinterStatus -value $Printer.printerstatus
        $print | add-member -MemberType NoteProperty -name PrinterPortName -value $Printer.PortName
        $print | add-member -MemberType NoteProperty -name Alive -value $(If (Test-connection $Printer.PortName -count 1 -ea SilentlyContinue){$True}Else{$false})
        $PrintRpt += $Print
        }
    }

#$PrintRpt | ft -AutoSize

Function Create-Report {
$UP = $PrintRpt | ? {$_.alive -eq $True} | ft -AutoSize
$Down = $PrintRpt | ? {$_.alive -eq $False} | ft -AutoSize

$FQDN_UP = $PrintRpt | ? {($_.printerstatus -eq 3) -and ($_.printerportname -notlike "10.*")} | ft -AutoSize
$IP_UP = $PrintRpt | ? {($_.printerstatus -eq 3) -and ($_.printerportname -like "10.*")} | ft -AutoSize
$FQDN_Down = $PrintRpt | ? {($_.printerstatus -ne 3) -and ($_.printerportname -notlike "10.*")} | ft -AutoSize
$IP_Down = $PrintRpt | ? {($_.printerstatus -ne 3) -and ($_.printerportname -like "10.*")} | ft -AutoSize

"`nTotal printers         " + $PrintRpt.count
"Print Device alive     " + $Up.count
"Print Device not alive " + $Down.count

"`nStatus = 3     " + $($IP_Up.Count + $FQDN_Up.Count)
"Status not = 3 " + $($IP_Down.Count + $FQDN_Down.Count)

"`nStatus = 3 using FQDN   " + $FQDN_UP.Count
"Status = 3 using IP " + $IP_UP.Count

"`nStatus not = 3  using FQDN " + $FQDN_Down.Count
"Status not = 3 using IP    " + $IP_Down.Count

<#
"`nPrinters that are ALive     " + $FQDN_UP.Count
$UP

"Printers that are not Alive " + $FQDN_UP.Count
$Down
#>

"`nPrinters that are up using FQDN " + $FQDN_UP.Count
$FQDN_UP

"`nPrinters that are up using IP " + $IP_UP.Count
$IP_UP

"`nPrinters that are down using FQDN " + $FQDN_Down.Count
$FQDN_Down

"Printers that are down using IP " + $IP_Down.Count
$IP_Down
}

Create-Report | Out-File c:\printer_report.txt