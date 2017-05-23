$xoml = @"
<ns0:SequentialWorkflow 
  ActorId="00000000-0000-0000-0000-000000000000" 
  RequestId="00000000-0000-0000-0000-000000000000" 
  x:Name="SequentialWorkflow" 
  TargetId="00000000-0000-0000-0000-000000000000" 
  WorkflowDefinitionId="00000000-0000-0000-0000-000000000000" 
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
  xmlns:ns0="clr-namespace:Microsoft.ResourceManagement.Workflow.Activities;Assembly=Microsoft.ResourceManagement, Version=4.3.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35">
	
<ns0:SynchronizationRuleActivity AddValue="{x:Null}" 
  Action="Add" 
  SynchronizationRuleId="69de1817-9443-412d-9fe8-76ef3791d443" 
  AttributeId="00000000-0000-0000-0000-000000000000" 
  RemoveValue="{x:Null}" 
  x:Name="authenticationGateActivity1">

<ns0:SynchronizationRuleActivity.Parameters>
  x:Array Type="{x:Type ns0:SynchronizationRuleParameter}" />
/ns0:SynchronizationRuleActivity.Parameters>
/ns0:SynchronizationRuleActivity>
/ns0:SequentialWorkflow>
"@ -F (Get-FimObjectID EmailTemplate DisplayName "!MC Users Active")


New-FimImportObject -objectType WorkflowDefinition -State Create -Changes @{
	DisplayName 		= '!!MC Users Active'
	Description        	= 'Active Users'
	RequestPhase 	   	= 'Action'
	RunOnPolicyUpdate	= 'True'
	XOML = $xoml
} -ApplyNow 