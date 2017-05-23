#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Confirm $true
Clear
$ComputerName = "PSTXLAB01.MATC.Madison.Login"
#$ComputerName = Read-Host "Enter the print server name."
 
[bool] $QueryData = $true
[bool] $OutputFiles = $true
 
function Ping()
{
 param ([string] $ComputerName)
 [bool] $Pingable = $false
   
 try{
  $ping = new-object System.Net.NetworkInformation.Ping
  $Reply = $ping.send($ComputerName, 100)
  if ($Reply.status –eq “Success”) 
  {
   $Pingable = $true
  }
 } 
 catch
 {
  return "Error Resloving $ComputerName"
 }
  
 if ($Pingable) 
 {
  return “Online”
 }
 else 
 {
  return "Offline"
 }
}
Function Get-Printers( )
{
 param ([string] $ComputerName  = ".") #sets "." as the default param if none is supplied
 
  
 Write-Host "Connecting to $ComputerName by WMI to gather printer information."
 Write-Host "Warning this may take a few minutes depending how many printers there are." -ForegroundColor Red
  
 $colItems = get-wmiobject -class "Win32_Printer" -namespace "root\CIMV2" -computername $ComputerName
 $count = $colItems.Count
 $pos = 0
 Write-Host "Found $count printers. Getting details on each now."
 $Printers = @()
 
 foreach ($objItem in $colItems) 
 {
  write-progress -activity "Getting Information on each printer." -status "% Complete" -percentcomplete (($pos++/$count)*100);
         
  #$list = "" | select "AvgPagesPerMinute", "Caption", "Comment", "Default", "DriverName" ,"InstallDate", "JobCountSinceLastReset", "Local", "Location" ,"Name", `
  #"Network", "PortName", "PrinterStatus", "PrintJobDataType", "PrintProcessor", "Shared", "ShareName", "Status", "StatusInfo", "SystemName" , "WorkOffline"
   
  #creating a new object called $PrinterInfo 
         $PrinterInfo = New-Object psobject  
        
         #write-host "Attributes: " $objItem.Attributes
         #write-host "Availability: " $objItem.Availability
         #write-host "Available Job Sheets: " $objItem.AvailableJobSheets
         $PrinterInfo | Add-Member NoteProperty NameAvgPagesPerMinute $objItem.AveragePagesPerMinute 
         #write-host "Capabilities: " $objItem.Capabilities
         #write-host "Capability Descriptions: " $objItem.CapabilityDescriptions
         $PrinterInfo | Add-Member NoteProperty Caption $objItem.Caption
         #write-host "Character Sets Supported: " $objItem.CharSetsSupported
         $PrinterInfo | Add-Member NoteProperty Comment  $objItem.Comment
         #write-host "Configuration Manager Error Code: " $objItem.ConfigManagerErrorCode
         #write-host "Configuration Manager User Configuration: " $objItem.ConfigManagerUserConfig
         #write-host "Creation Class Name: " $objItem.CreationClassName
         #write-host "Current Capabilities: " $objItem.CurrentCapabilities
         #write-host "Current Character Set: " $objItem.CurrentCharSet
         #write-host "Current Language: " $objItem.CurrentLanguage
         #write-host "Current MIME Type: " $objItem.CurrentMimeType
         #write-host "Current Natural Language: " $objItem.CurrentNaturalLanguage
         #write-host "Current Paper Type: " $objItem.CurrentPaperType
         $PrinterInfo | Add-Member NoteProperty "Default"  $objItem.Default
         #write-host "Default Capabilities: " $objItem.DefaultCapabilities
         #write-host "Default Copies: " $objItem.DefaultCopies
         #write-host "Default Language: " $objItem.DefaultLanguage
         #write-host "Default MIME Type: " $objItem.DefaultMimeType
         #write-host "Default Number Up: " $objItem.DefaultNumberUp
         #write-host "Default Paper Type: " $objItem.DefaultPaperType
         #write-host "Default Priority: " $objItem.DefaultPriority
         #write-host "Description: " $objItem.Description
         #write-host "Detected Error State: " $objItem.DetectedErrorState
         #write-host "Device ID: " $objItem.DeviceID
         #write-host "Direct: " $objItem.Direct
         #write-host "Do Complete First: " $objItem.DoCompleteFirst
         $PrinterInfo | Add-Member NoteProperty "DriverName" $objItem.DriverName
         #write-host "Enable BIDI: " $objItem.EnableBIDI
         #write-host "Enable Device Query Print: " $objItem.EnableDevQueryPrint
         #write-host "Error Cleared: " $objItem.ErrorCleared
         #write-host "Error Description: " $objItem.ErrorDescription
         #write-host "Error Information: " $objItem.ErrorInformation
         #write-host "Extended Detected Error State: " $objItem.ExtendedDetectedErrorState
         #write-host "Extended Printer Status: " $objItem.ExtendedPrinterStatus
         #write-host "Hidden: " $objItem.Hidden
         #write-host "Horizontal Resolution: " $objItem.HorizontalResolution
         #$PrinterInfo | Add-Member NoteProperty "InstallDate" $objItem.InstallDate
         $PrinterInfo | Add-Member NoteProperty "JobCountSinceLastReset" $objItem.JobCountSinceLastReset
         #write-host "Keep Printed Jobs: " $objItem.KeepPrintedJobs
         #write-host "Languages Supported: " $objItem.LanguagesSupported
         #write-host "Last Error Code: " $objItem.LastErrorCode
         $PrinterInfo | Add-Member NoteProperty "Local" $objItem.Local
         $PrinterInfo | Add-Member NoteProperty "Location" $objItem.Location
         #write-host "Marking Technology: " $objItem.MarkingTechnology
         #write-host "Maximum Copies: " $objItem.MaxCopies
         #write-host "Maximum Number Up: " $objItem.MaxNumberUp
         #write-host "Maximum Size Supported: " $objItem.MaxSizeSupported
         #write-host "MIME Types Supported: " $objItem.MimeTypesSupported
         $PrinterInfo | Add-Member NoteProperty "Name" $objItem.Name
         #write-host "Natural Languages Supported: " $objItem.NaturalLanguagesSupported
         $PrinterInfo | Add-Member NoteProperty "Network" $objItem.Network
         #write-host "Paper Sizes Supported: " $objItem.PaperSizesSupported
         #write-host "Paper Types Available: " $objItem.PaperTypesAvailable
         #write-host "Parameters: " $objItem.Parameters
         #write-host "PNP Device ID: " $objItem.PNPDeviceID
         $PrinterInfo | Add-Member NoteProperty "PortName" $objItem.PortName
         #write-host "Power Management Capabilities: " $objItem.PowerManagementCapabilities
         #write-host "Power Management Supported: " $objItem.PowerManagementSupported
         #write-host "Printer Paper Names: " $objItem.PrinterPaperNames
         #write-host "Printer State: " $objItem.PrinterState
         $PrinterInfo | Add-Member NoteProperty "PrinterStatus" $objItem.PrinterStatus
         $PrinterInfo | Add-Member NoteProperty "PrintJobDataType" $objItem.PrintJobDataType
         $PrinterInfo | Add-Member NoteProperty "PrintProcessor" $objItem.PrintProcessor
         #write-host "Priority: " $objItem.Priority
         #write-host "Published: " $objItem.Published
         #write-host "Queued: " $objItem.Queued
         #write-host "Raw-Only: " $objItem.RawOnly
         #write-host "Separator File: " $objItem.SeparatorFile
         #write-host "Server Name: " $objItem.ServerName
         $PrinterInfo | Add-Member NoteProperty "Shared" $objItem.Shared
         $PrinterInfo | Add-Member NoteProperty "ShareName" $objItem.ShareName
         #write-host "Spool Enabled: " $objItem.SpoolEnabled
         #write-host "Start Time: " $objItem.StartTime
         $PrinterInfo | Add-Member NoteProperty "Status" $objItem.Status
         $PrinterInfo | Add-Member NoteProperty "StatusInfo" $objItem.StatusInfo
         #write-host "System Creation Class Name: " $objItem.SystemCreationClassName
         $PrinterInfo | Add-Member NoteProperty "SystemName" $objItem.SystemName
         #write-host "Time Of Last Reset: " $objItem.TimeOfLastReset
         #write-host "Until Time: " $objItem.UntilTime
         #write-host "Vertical Resolution: " $objItem.VerticalResolution
         $PrinterInfo | Add-Member NoteProperty "WorkOffline" $objItem.WorkOffline
          
  $Printers += $PrinterInfo
         
 }
 write-progress -activity "Getting Information on each Port." -status "% Complete:" -percentcomplete 100 -Completed;
 return $Printers
}
 
function Get-PortInfo ()
{
 param ([string] $ComputerName  = ".") #sets "." as the default param if none is supplied
  
   
 Write-Host "Connecting to $ComputerName by WMI to gather printer port information."
 Write-Host "Warning this may take a few minutes because its pinging each port." -ForegroundColor Red
  
  
  
  
 $colItems = get-wmiobject -class "Win32_TCPIPPrinterPort" -namespace "root\CIMV2" -computername $ComputerName
 $count = $colItems.Count
 $pos = 0
 Write-Host "Found $count printer ports. Getting details on each now."
  
  
 $Ports = @()
  
 foreach ($objItem in $colItems)
 {
  write-progress -activity "Getting Information on each Port." -status "% Complete:" -percentcomplete (($pos++/$count)*100);
   
  $PortInfo = New-Object psobject  
  $PortInfo | Add-Member NoteProperty "ByteCount" $objItem.ByteCount
  $PortInfo | Add-Member NoteProperty "Caption: " $objItem.Caption
  $PortInfo | Add-Member NoteProperty "CreationClassName" $objItem.CreationClassName
  $PortInfo | Add-Member NoteProperty "Description: " $objItem.Description
  $PortInfo | Add-Member NoteProperty "HostAddress" $objItem.HostAddress
  $PortInfo | Add-Member NoteProperty "InstallDate" $objItem.InstallDate
  $PortInfo | Add-Member NoteProperty "Name" $objItem.Name
  $PortInfo | Add-Member NoteProperty "PortNumber" $objItem.PortNumber
  $PortInfo | Add-Member NoteProperty "Protocol" $objItem.Protocol
  $PortInfo | Add-Member NoteProperty "Queue" $objItem.Queue
  $PortInfo | Add-Member NoteProperty "SNMPCommunity" $objItem.SNMPCommunity
  $PortInfo | Add-Member NoteProperty "SNMPDevIndex" $objItem.SNMPDevIndex
  $PortInfo | Add-Member NoteProperty "SNMPEnabled" $objItem.SNMPEnabled
  $PortInfo | Add-Member NoteProperty "Status" $objItem.Status
  $PortInfo | Add-Member NoteProperty "SystemCreationClassName" $objItem.SystemCreationClassName
  $PortInfo | Add-Member NoteProperty "SystemName" $objItem.SystemName
  $PortInfo | Add-Member NoteProperty "Type" $objItem.Type
  $PortInfo | Add-Member NoteProperty "Ping" (Ping -ComputerName $objItem.HostAddress)
   
  $Ports += $PortInfo
 }
 write-progress -activity "Getting Information on each Port." -status "% Complete:" -percentcomplete 100 -Completed;
 return $Ports
}
function Get-PritnersWithPort {
param ( [array] $Printers,
  [array] $Ports  )
 
  
 $PrinterWithPortInfo = @()
 Foreach($Printer in $Printers)
 {
  $Port = $Ports | where {$_.Name -like ($Printer.PortName) }
  if($Port -ne $null)
  {
   $properties = $Port | Get-Member -MemberType NoteProperty
        
   foreach ($member in $properties )
   {
        $PropName = $member.Name
        $PropValue = $Port | Get-Member -MemberType NoteProperty ($member.Name) 
         
        $PropValue = $PropValue.ToString().Split("=")[1]
         
        if($PropValue -match "null")
        { $PropValue = ""}
         
        $Printer | Add-Member NoteProperty ("Port_" + $Propname) $PropValue
   }
  }
  $PrinterWithPortInfo += $Printer
 }
 return $PrinterWithPortInfo
}
 
function Get-PortsWithPrinterAndOnline
{
param ( [array] $Printers , 
  [array] $Ports  )
  
 $PortsWithPrinterAndOnline = @()
 Foreach($Printer in $Printers)
 {
   $Port = $Ports | where { $_.Name -like ($Printer.PortName) -and ( $_.Ping -like "Online") }
   $PortsWithPrinterAndOnline += $Port
 }
  
 return $PortsWithPrinterAndOnline
}
 
 
 
 
function CreatePrinterPort {
 param ( [string] $ComputerName  = ".", #sets "." as the default param if none is supplied
  [string] $PortName ,
  [string] $DNSName ,
  [int] $Protocol = 1,  #default of 1 for RAW
  [string]$Queue = $null,
  [string]$PortNumber =  "9100",
  [bool] $SNMPEnabled ,
  [string] $SNMPCommunity = $null)
  
 
 #$newPort = [wmiclass]"Win32_TcpIpPrinterPort"
 #$port = get-wmiobject -class "Win32_TCPIPPrinterPort" -namespace "root\CIMV2" -computername $ComputerName
 $newPort = ([WMICLASS]"\\$ComputerName\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance() 
 $newport.Name= $PortName
 $newport.HostAddress= $DNSName #sometimes IP Address
 $newport.Protocol= $Protocol
 #Protocols possiable
 #1 = RAW, Printing directly to a device or print server.
 #2 = LPR, Legacy protocol, which is eventually replaced by RAW.
  
 if ($Protocol -eq 2 ) {
  $newport.Queue = $Queue
 }
  
  
 $newPort.PortNumber = "9100"
 $newport.SNMPEnabled = $SNMPEnabled
  
 if( $SNMPCommunity -ne $null ) {
  $newport.SNMPCommunity = $SNMPCommunity
 }
 Write-Host "Creating Port $PortName" -foregroundcolor "darkgreen"
 [void] $newport.Put()
  
  
}
#################################################################################
#               MAIN               #
#################################################################################
 
 
#Formated File Names
$d = get-date
$FileTime = "" + $d.Year + "-" + $d.Month + "-" + $d.Day + "-" + $d.Hour + $d.Minute
$PortsFilename = [String]::Format( "{0}_Ports_{1}.csv", $ComputerName, $FileTime )
$PritnersFilename = [String]::Format( "{0}_Printers_{1}.csv", $ComputerName, $FileTime )
$PritnersWithPortFilename = [String]::Format( "{0}_PritnersWithPort_{1}.csv", $ComputerName, $FileTime )
 
if( $QueryData )
{
 #Gets all the information
 $Printers = Get-Printers -ComputerName $ComputerName
 $Ports = Get-PortInfo -ComputerName $ComputerName
 $PrinterWithPortInfo = Get-PritnersWithPort -Printers $Printers -Ports  $Ports
}
 
if($OutputFiles)
{
 #writing file to 
 [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath 
 Write-Host ("Saving CSV Files at " + [Environment]::CurrentDirectory + " Named the following.")
 Write-Host $PortsFilename
 Write-Host $PritnersFilename
 Write-Host $PritnersWithPortFilename
 
 $Printers | Sort-Object "Name" | Export-Csv $PritnersFilename
 $Ports | Sort-Object "Name" | Export-Csv $PortsFilename
 $PrinterWithPortInfo | Sort-Object "Name" | Export-Csv $PritnersWithPortFilename
  
 
 #removes the top line as it just has #TYPE System.Management.Automation.PSCustomObject in it.
 get-content $PritnersFilename |  select -Skip 1 |  set-content "$PritnersFilename-temp"
 move  "$PritnersFilename-temp" $PritnersFilename -Force
 
 get-content $PortsFilename |  select -Skip 1 |  set-content "$PortsFilename-temp"
 move  "$PortsFilename-temp" $PortsFilename -Force
  
 get-content $PritnersWithPortFilename |  select -Skip 1 |  set-content "$PritnersWithPortFilename-temp"
 move  "$PritnersWithPortFilename-temp" $PritnersWithPortFilename -Force
  
}
