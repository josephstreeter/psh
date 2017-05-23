
###
### Create the MPR: 'Congratulate New Craigs'
###
New-FimImportObject -ObjectType ManagementPolicyRule -State Create -Changes @{
    GrantRight			= 'False'
    Disabled			= 'False'
    DisplayName			= '!!MC Users Active' 
    Description			= 'Active Users'
    ManagementPolicyRuleType	= 'SetTransition'    
    ActionType			= 'TransitionIn'
    ResourceFinalSet		= ('Set', 'DisplayName', 'All Craigs')
    ActionWorkflowDefinition	= ('WorkflowDefinition','DisplayName','!MC Users Active')  
} -ApplyNow