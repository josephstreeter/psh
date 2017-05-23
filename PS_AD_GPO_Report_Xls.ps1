http://syswow.blogspot.com/2012/06/group-policy-status-excel-report.html

import-module grouppolicy

$Policies = $Args[0] 

#-----------------------------------------------
# Functions
#-----------------------------------------------

#Get-GPOInfo gets an XML report of the GPO and uses it to return specific data in an array

function Get-GPOInfo
{
 param($GPOGUID)
 #Gets the XML version of the GPO Report
 $GPOReport = get-gporeport -guid $GPOGUID -reporttype XML
 #Converts it to an XML variable for manipulation
 $GPOXML = [xml]$GPOReport
 #Create array to store info
 $GPOInfo = @()
 #Get's info from XML and adds to array
 #General Information

 $Name = $GPOXML.GPO.Name
 $GPOInfo += , $Name

 $GUID = $GPOXML.GPO.Identifier.Identifier.'#text'
 $GPOInfo += , $GUID

 [DateTime]$Created = $GPOXML.GPO.CreatedTime

 $GPOInfo += , $Created.ToString("G")

 

 [DateTime]$Modified = $GPOXML.GPO.ModifiedTime

 $GPOInfo += , $Modified.ToString("G")

 

 #WMI Filter

 if ($GPOXML.GPO.FilterName) {

  $WMIFilter = $GPOXML.GPO.FilterName

 } else {

  $WMIFilter = "<none>"

 }

 $GPOInfo += , $WMIFilter

 

 #Computer Configuration

 $ComputerEnabled = $GPOXML.GPO.Computer.Enabled

 $GPOInfo += , $ComputerEnabled

 

 $ComputerVerDir = $GPOXML.GPO.Computer.VersionDirectory

 $GPOInfo += , $ComputerVerDir

 

 $ComputerVerSys = $GPOXML.GPO.Computer.VersionSysvol

 $GPOInfo += , $ComputerVerSys

 

 if ($GPOXML.GPO.Computer.ExtensionData) { 

  $ComputerExtensions = $GPOXML.GPO.Computer.ExtensionData | %{ $_.Name }

  $ComputerExtensions = [string]::join("`n", $ComputerExtensions)

 } else {

  $ComputerExtensions = "<none>"

 }

 $GPOInfo += , $ComputerExtensions

 

 #User Configuration

 $UserEnabled = $GPOXML.GPO.User.Enabled

 $GPOInfo += , $UserEnabled

 

 $UserVerDir = $GPOXML.GPO.User.VersionDirectory

 $GPOInfo += , $UserVerDir

 

 $UserVerSys = $GPOXML.GPO.User.VersionSysvol

 $GPOInfo += , $UserVerSys

 

 if ($GPOXML.GPO.User.ExtensionData) {

  $UserExtensions = $GPOXML.GPO.User.ExtensionData | %{ $_.Name }

  $UserExtensions = [string]::join("`n", $UserExtensions)

 } else {

  $UserExtensions = "<none>"

 }

 $GPOInfo += , $UserExtensions

 

 #Links

 if ($GPOXML.GPO.LinksTo) {

  $Links = $GPOXML.GPO.LinksTo | %{ $_.SOMPath }

  $Links = [string]::join("`n", $Links)

  $LinksEnabled = $GPOXML.GPO.LinksTo | %{ $_.Enabled }

  $LinksEnabled = [string]::join("`n", $LinksEnabled)

  $LinksNoOverride = $GPOXML.GPO.LinksTo | %{ $_.NoOverride }

  $LinksNoOverride = [string]::join("`n", $LinksNoOverride)

 } else {

  $Links = "<none>"

  $LinksEnabled = "<none>"

  $LinksNoOverride = "<none>"

 }

 $GPOInfo += , $Links

 $GPOInfo += , $LinksEnabled

 $GPOInfo += , $LinksNoOverride

 

 #Security Info

 $Owner = $GPOXML.GPO.SecurityDescriptor.Owner.Name.'#text'

 $GPOInfo += , $Owner

 

 $SecurityInherits = $GPOXML.GPO.SecurityDescriptor.Permissions.InheritsFromParent

 $SecurityInherits = [string]::join("`n", $SecurityInherits)

 $GPOInfo += , $SecurityInherits

 

 $SecurityGroups = $GPOXML.GPO.SecurityDescriptor.Permissions.TrusteePermissions | %{ $_.Trustee.Name.'#text' }

 $SecurityGroups = [string]::join("`n", $SecurityGroups)

 $GPOInfo += , $SecurityGroups

 

 $SecurityType = $GPOXML.GPO.SecurityDescriptor.Permissions.TrusteePermissions | % { $_.Type.PermissionType }

 $SecurityType = [string]::join("`n", $SecurityType)

 $GPOInfo += , $SecurityType

 

 $SecurityPerms = $GPOXML.GPO.SecurityDescriptor.Permissions.TrusteePermissions | % { $_.Standard.GPOGroupedAccessEnum }

 $SecurityPerms = [string]::join("`n", $SecurityPerms)

 $GPOInfo += , $SecurityPerms

 

 #Policy File System Size

 #$GPOSize = Get-GPOSize $GUID $Policies

 #$GPOInfo += , $GPOSize.Total

 #$GPOInfo += , $GPOSize.Policy

 #$GPOInfo += , $GPOSize.ADM

 #$GPOInfo += , $GPOSize.ADMFiles



    return $GPOInfo

}




#Get-GPOSize returns the GPO file size. It requires a GUID and the sysvol policy path. It returns a Hash Table with three sizes (in Bytes) Total/ADM/Policy

function Get-GPOSize

{
 param($GPOGUID,$PoliciesPath)
 #Creates $objFSO if not already created

 if (!$objFSO) { $objFSO = New-Object -com  Scripting.FileSystemObject }
 $PolicyPath = $PoliciesPath + $GPOGUID
 $ADMPath = $PolicyPath + "\Adm"

 $TotalSize = $objFSO.GetFolder($PolicyPath).Size

 if (test-path $ADMPath) { 
  $ADMSize = $objFSO.GetFolder($ADMPath).Size
  $Files = $objFSO.GetFolder($ADMPath).Files | %{ $_.Name }

  if ($Files) { $ADMFiles = [string]::join("`n", $Files) } else { $ADMFiles = "<none>" }

 } else { 

  $ADMSize = 0 

  $ADMFiles = "<none>"

 }

 $PolicySize = $TotalSize - $ADMSize

 

 $Size = @{"Total" = $TotalSize.ToString(); "ADM" = $ADMSize.ToString(); "Policy" = $PolicySize.ToString(); "ADMFiles" = $ADMFiles}

 

 return $Size

}




#-----------------------------------------------

# Get's list of GPO's

#-----------------------------------------------




write-host Getting GPO Information...

$GPOs = get-gpo -all

write-host `tGPOs: $GPOs.Count




#-----------------------------------------------

# Creates an array and populates it with GPO information arrays

#-----------------------------------------------




$AllGPOs = @()




write-host Getting GPO XML Reports...




$GPOCount = 0

$GPOs | foreach-object {




 $GPOCount++

 write-host `t$GPOCount : $_.DisplayName / $_.ID

 $ThisGPO = get-gpoinfo $_.ID

 $AllGPOs += ,$ThisGPO




}




#-----------------------------------------------------

# Exports all information to Excel (nicely formatted)

#-----------------------------------------------------




write-host Exporting information to Excel...




#Excel Constants

$White = 2

$DarkGrey = 56

$Center = -4108

$Top = -4160




$e = New-Object -comobject Excel.Application

$e.Visible = $True #Change to Hide Excel Window

$e.DisplayAlerts = $False

$wkb = $E.Workbooks.Add()

$wks = $wkb.Worksheets.Item(1)




#Builds Top Row

$wks.Cells.Item(1,1) = "GPO Name"

$wks.Cells.Item(1,2) = "GUID"

$wks.Cells.Item(1,3) = "Created"

$wks.Cells.Item(1,4) = "Last Modified"

$wks.Cells.Item(1,5) = "WMI Filter"

$wks.Cells.Item(1,6) = "Comp Config"

$wks.Cells.Item(1,7) = "Comp Dir Ver"

$wks.Cells.Item(1,8) = "Comp Sysvol Ver"

$wks.Cells.Item(1,9) = "Comp Extensions"

$wks.Cells.Item(1,10) = "User Config"

$wks.Cells.Item(1,11) = "User Dir Ver"

$wks.Cells.Item(1,12) = "User Sysvol Ver"

$wks.Cells.Item(1,13) = "User Extensions"

$wks.Cells.Item(1,14) = "Links"

$wks.Cells.Item(1,15) = "Enabled"

$wks.Cells.Item(1,16) = "No Override"

$wks.Cells.Item(1,17) = "Owner"

$wks.Cells.Item(1,18) = "Inherits"

$wks.Cells.Item(1,19) = "Groups"

$wks.Cells.Item(1,20) = "Perm Type"

$wks.Cells.Item(1,21) = "Permissions"

$wks.Cells.Item(1,22) = "Total Size"

$wks.Cells.Item(1,23) = "Policy Size"

$wks.Cells.Item(1,24) = "ADM Size"

$wks.Cells.Item(1,25) = "ADM Files"




#Formats Top Row

$wks.Range("A1:Y1").font.bold = "true"

$wks.Range("A1:Y1").font.ColorIndex = $White

$wks.Range("A1:Y1").interior.ColorIndex = $DarkGrey




#Fills in Data from Array

$row = 2

$AllGPOs | foreach {

  $wks.Cells.Item($row,1) = $_[0]

  $wks.Cells.Item($row,2) = $_[1]

  $wks.Cells.Item($row,3) = $_[2]

  $wks.Cells.Item($row,4) = $_[3]

  $wks.Cells.Item($row,5) = $_[4]

  $wks.Cells.Item($row,6) = $_[5]

  $wks.Cells.Item($row,7) = $_[6]

  $wks.Cells.Item($row,8) = $_[7]

  $wks.Cells.Item($row,9) = $_[8]

  $wks.Cells.Item($row,10) = $_[9]

  $wks.Cells.Item($row,11) = $_[10]

  $wks.Cells.Item($row,12) = $_[11]

  $wks.Cells.Item($row,13) = $_[12]

  $wks.Cells.Item($row,14) = $_[13]

  $wks.Cells.Item($row,15) = $_[14]

  $wks.Cells.Item($row,16) = $_[15]

  $wks.Cells.Item($row,17) = $_[16]

  $wks.Cells.Item($row,18) = $_[17]

  $wks.Cells.Item($row,19) = $_[18]

  $wks.Cells.Item($row,20) = $_[19]

  $wks.Cells.Item($row,21) = $_[20]

  $wks.Cells.Item($row,22) = $_[21]

  $wks.Cells.Item($row,23) = $_[22]

  $wks.Cells.Item($row,24) = $_[23]

  $wks.Cells.Item($row,25) = $_[24]

  $row++

}




#Adjust Formatting to make it easier to read

$wks.Range("I:I").Columns.ColumnWidth = 150

$wks.Range("M:M").Columns.ColumnWidth = 150

$wks.Range("N:N").Columns.ColumnWidth = 150

$wks.Range("S:S").Columns.ColumnWidth = 150

$wks.Range("Q:Q").Columns.ColumnWidth = 150

$wks.Range("U:U").Columns.ColumnWidth = 150

$wks.Range("Y:Y").Columns.ColumnWidth = 150

[void]$wks.Range("A:Y").Columns.AutoFit()

$wks.Range("A:U").Columns.VerticalAlignment = $Top

$wks.Range("F:H").Columns.HorizontalAlignment = $Center

$wks.Range("J:L").Columns.HorizontalAlignment = $Center

$wks.Range("R:R").Columns.HorizontalAlignment = $Center

$wks.Range("V:X").Columns.HorizontalAlignment = $Center


 #Save the file

$Path = Get-Location

$SaveFile = $Path.path + "\GPO_Report.xlsx"

$wkb.SaveAs($SaveFile)




#$e.Quit()