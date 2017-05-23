$template = '<config version="1.0" encoding="utf-8">
    <task>
        <name>Task 1</name>
        <status>Incomplete</status>
        <username>not set</username>
        <description>not set</description>
    </task>
    <task>
        <name>Task 2</name>
        <status>Incomplete</status>
    </task>
    <task>
        <name>Task 3</name>
        <status>Incomplete</status>
    </task>
 </config>'


$Path = "C:\Scripts\template.xml"

Function Create-Template
    {
    If (-not (Get-Item $Path))
        {
        $Template | Out-File $Path
        $xml = New-Object XML
        }
    }

Function Complete-Task1 
    {
    $UserName = Read-Host "Enter Username"
    $user = Get-ADUser $UserName
    $xml.config.task | ? {$_.name -eq "Task 1"} | % {$_.status = "done";$_.Username = $User.samaccountname;$_.Description = $User.Description}
    Save-Document
    Load-Menu
    }

Function Complete-Task2 
    {
    $xml.config.task | ? {$_.name -eq "Task 2"} | % {$_.status = "done"}
    Save-Document
    Load-Menu
    }

Function Complete-Task3
    {
    $xml.config.task | ? {$_.name -eq "Task 3"} | % {$_.status = "done"}
    Save-Document
    Load-Menu
    }

Function Save-Document
    {
    $Xml.Save($Path)
    }

Function Load-Document 
    {
    $Xml.Load($Path)
    }

Function Reset-Xml
    {
    Remove-Item $Path
    Create-Template
    Load-Menu
    }

Function Load-Menu 
    {
    Load-Document
    Clear-Host
    "Tasks"
    "`t 1 " + $xml.config.task.name[0] + " " + $xml.config.task.status[0] + " " + $xml.config.task.username[0] + " " + $xml.config.task.description[0]
    "`t 2 " + $xml.config.task.name[1] + " " + $xml.config.task.status[1]
    "`t 3 " + $xml.config.task.name[2] + " " + $xml.config.task.status[2]
    "`t 4 Reset XML"
    "`t 5 Quit"
    $Option = Read-Host "Select Task"
    Switch ($Option) {
        1 {Complete-Task1}
        2 {Complete-Task2}
        3 {Complete-Task3}
        4 {Reset-Xml}
        5 {Break}
        Default {Load-Menu}
        }
    }

Create-Template
Load-Menu