


$WorkflowDN = 'CN=New-GPO,CN=CADS,CN=Workflow,CN=Policies,CN=Configuration'
$Workflow = [ADSI]('EDMS://'+$WorkflowDN)

if (($Workflow -eq $null) -or ($Workflow.Guid -eq $null)) {
    $EventLog.ReportEvent($Constants.EDS_EVENTLOG_WARNING_TYPE, "Failed to launch the notification workflow `'$WorkflowDN`' as the workflow could not be bound.")
    return
    }



[xml]$ParametersXML = '<?xml version="1.0" encoding="utf-8"?>'+`
    '<RunParameterValues xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:schemas-quest-com:ActiveRolesServer:WorkflowParameters">'+`
    '  <RunParameterValue name="Domain" syntax="String">'+`
    '    <Values>'+`
    '      <Value isEncrypted="false">'+`
    '        <RawValue></RawValue>'+`
    '      </Value>'+`
    '    </Values>'+`
    '  </RunParameterValue>'+`
    '  <RunParameterValue name="Name" syntax="String">'+`
    '    <Values>'+`
    '      <Value isEncrypted="false">'+`
    '        <RawValue></RawValue>'+`
    '      </Value>'+`
    '    </Values>'+`
    '  </RunParameterValue>'+`
    '</RunParameterValues>'

$xmlNS = New-Object -TypeName System.Xml.XmlNamespaceManager($ParametersXML.NameTable)
$xmlNS.AddNamespace('ARS','urn:schemas-quest-com:ActiveRolesServer:WorkflowParameters')
$ParameterNode = $ParametersXML.SelectSingleNode('/ARS:RunParameterValues/ARS:RunParameterValue[@name="Domain"]/ARS:Values/ARS:Value/ARS:RawValue',$xmlNS)
$ParameterNode.set_InnerText("ad.wisc.edu") # $Request.Get('distinguishedName')
$ParameterNode = $ParameterNode.SelectSingleNode('/ARS:RunParameterValues/ARS:RunParameterValue[@name="Name"]/ARS:Values/ARS:Value/ARS:RawValue',$xmlNS)
$ParameterNode.set_InnerText("Test-GPO") # $DirObj.Get('displayName')


$Workflow.Put('edsvaStartWorkflow','TRUE')
$Workflow.Put('edsvaWorkflowRunParameterValues', $ParametersXML.OuterXml)
$Workflow.SetInfo()