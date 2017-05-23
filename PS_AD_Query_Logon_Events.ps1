$Events = Get-WinEvent -FilterHashtable @{LogName="Security";id=4624} -ErrorAction Stop            
$File="C:\psoft-logon.csv"

$Entry=@()        
ForEach ($Event in $Events) 
    {            
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()                   
    if ($($eventXML.Event.EventData.Data[5].'#text') -match "psoftuser")
        {
        $Entry+=New-Object psobject -Property @{
            $eventXML.Event.EventData.Data[5].name = $eventXML.Event.EventData.Data[5].'#text'
            $eventXML.Event.EventData.Data[4].name = $eventXML.Event.EventData.Data[4].'#text'
            $eventXML.Event.EventData.Data[6].name = $eventXML.Event.EventData.Data[6].'#text'
            $eventXML.Event.EventData.Data[8].name = $eventXML.Event.EventData.Data[8].'#text'
            $eventXML.Event.EventData.Data[10].name = $eventXML.Event.EventData.Data[10].'#text'
            $eventXML.Event.EventData.Data[11].name = $eventXML.Event.EventData.Data[11].'#text'
            $eventXML.Event.EventData.Data[18].name = $eventXML.Event.EventData.Data[18].'#text'
            }

        if ($File)
            {
            $Entry | Convertto-CSV -NoTypeInformation |select -Skip 1 | Out-File $File -Append
            }
        Else
            {
            $Entry | Convertto-CSV -NoTypeInformation | Out-File $File
            }

        }
    }