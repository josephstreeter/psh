$Events = Get-WinEvent -ComputerName cadsdc-cssc-01 -FilterHashtable @{Logname='Security';Id=4625} #-MaxEvents 100            
            
# Parse out the event message data            
ForEach ($Event in $Events) {            
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()                       
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "Username" -Value $eventXML.Event.EventData.Data[5].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "Domain" -Value $eventXML.Event.EventData.Data[6].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "Reason" -Value $eventXML.Event.EventData.Data[8].'#text'
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "Auth-Package" -Value $eventXML.Event.EventData.Data[12].'#text'           
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "Workstation" -Value $eventXML.Event.EventData.Data[13].'#text'           
    }                     
            
# View the results with your favorite output method            
#$Events | Export-Csv .\events.csv            
$Events | Select-Object username,domain,reason,auth-package,workstation | ? {(-not ($_.username -like "*$"))} | ft -AutoSize