

<#
$template = '<?xml version="1.0" encoding="utf-8"?>
 <person>
     <sn>1</sn>
     <firstname>Tobias</firstname>
     <lastname>Weltner</lastname>
     </person>
 </employee>'
 #>
#$xml = New-Object XML
$Path = "C:\Scripts\template.xml"


Function Add-Employee 
    {
    $SN = ($xml.employee.person.sn).count
    $NewEmployee = $xml.Employee.Person[0].Clone()
    $NewEmployee.sn = ($SN).ToString()
    $NewEmployee.FirstName = (Read-Host "First Name").tostring()
    $NewEmployee.LastName = (Read-Host "Last Name").tostring()
    $Xml.DocumentElement.AppendChild($NewEmployee)
    Save-Document
    }

Function Change-Employee 
    {
    $EmplID = Read-Host "Enter Employee SN"
    $xml.Employee.Person | ? { $_.sn -eq $EmplID } | % { $_.firstname = (Read-Host "First Name ("$_.FirstName")").tostring() ; $_.LastName = (Read-Host "Last Name ("$_.LastName")").tostring()}
    Save-Document
    }

Function Save-Document
    {
    $Xml.Save($Path)
    Load-Document
    }

Function Load-Document 
    {
    $Xml.Load($Path)
    Load-Menu
    }

Function View-Employees
    {
    $xml.employee.person | sort sn | ft -auto
    Read-Host "Press Enter to Continue"
    Load-Menu
    }

Function Load-Menu 
    {
    Clear-Host
    "Tasks"
    "`t 1 Add Employee"
    "`t 2 Change Employee"
    "`t 3 View Employees"
    "`t 4 Quit"
    $Option = Read-Host "Select Task"
    Switch ($Option) {
        1 {Add-Employee}
        2 {Change-Employee}
        3 {View-Employees}
        4 {Break}
        Default {Load-Menu}
        }
    }

Load-Document