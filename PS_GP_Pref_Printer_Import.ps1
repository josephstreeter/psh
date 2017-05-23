$files = Get-ChildItem \\naf01a\startup$\scripts\prt
$template = '<SharedPrinter clsid="{9A5E9697-9095-436d-A0EE-4D128FDFBCE5}" name="PrinterName" status="PrinterName" image="2" changed="2015-09-18 20:46:16" uid="{GUID}" bypassErrors="1"><Properties action="C" comment="" path="PrinterPath" location="" default="0" skipLocal="0" deleteAll="0" persistent="0" deleteMaps="0" port=""/><Filters><FilterOrgUnit bool="AND" not="0" name="OU=OUName,OU=Win7_Workstations,OU=Student,DC=MATC,DC=Madison,DC=Login" userContext="0" directMember="0"/></Filters></SharedPrinter>'

'<?xml version="1.0" encoding="utf-8"?>
<Printers clsid="{1F577D12-3D1B-471e-A1B7-060317597B9C}">' | Out-File C:\Scripts\printer_preferences.xml 

Foreach ($File in $Files) 
    {
    $printers = Get-Content $file.FullName
        foreach ($Printer in $Printers)
            {
            if ($printer -match "AddWindowsPrinterConnection")
                {
                $sharedname = $printer.Replace("(New-Object -ComObject WScript.Network).AddWindowsPrinterConnection(","").Replace(")","").replace('"','').trim()
                $PrinterName = $sharedname.Split("\")[3]
                
                $guid = [System.Guid]::NewGuid().toString()
                $OUName = $PrinterName.Split("-")[0]
                                
                $Line = $template -replace "PrinterName", $PrinterName
                $line = $Line -replace "GUID", $GUID
                $line = $Line -replace "PrinterPath", $SharedName
                $line = $Line -replace "OUName", $OUName
                If ($(Get-Content $file.FullName) | Select-String "SetDefaultPrinter" | select-string $PrinterName){$line = $Line -replace 'default="0"', 'default="1"'}
                $line | Out-File -append C:\Scripts\printer_preferences.xml
                }
            }
    }
    "</Printers>" | Out-File -append C:\Scripts\printer_preferences.xml