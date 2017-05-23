# Configure database connection
$adOpenStatic = 3
$adLockOptimistic = 3

$conn=New-Object -com "ADODB.Connection"
$rs = New-Object -com "ADODB.Recordset"
$conn.Open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\users\joseph.streeter\desktop\STIG.accdb;Persist Security Info=True;')

$rs.Open("SELECT * FROM WS2012R2MS",$conn,$adOpenStatic,$adLockOptimistic)

# Get STIG info from XML
$xml = [xml] (Get-Content c:\users\joseph.streeter\desktop\STIGS\U_Windows2012_MS_v1r2_Manual-xccdf.xml)
$Rules = $xml.Benchmark.Group

Foreach ($Rule in $Rules) {
    "#############################"
    $discussion = "<test>"+$Rule.rule.description+"</test>"
    $discussion = [xml] $discussion

    $GroupID = $Rule.id
    $GroupTitle = $Rule.title
    $RuleTitle = $Rule.rule.title
    $id = $Rule.rule.id
    $Severity = $Rule.rule.severity
    $Weight = $Rule.rule.weight
    $Version = $Rule.rule.version
    $CheckContent = $Rule.rule.fixtext."#text"

    $VulnerabilityDiscussion = $discussion.test.VulnDiscussion

    If ($discussion.test.FalsePositives){
        $FalsePositives = $discussion.test.FalsePositives
    }Else{
        $FalsePositives = "None"
    }

    If ($discussion.test.FalseNegatives){
        $FalseNegatives =$discussion.test.FalseNegatives
    }Else{
        $FalseNegatives = "None"
    }

    $Documentable = $discussion.test.Documentable

    If ($discussion.test.FalseNegatives){
        $Mitigations = $discussion.test.Mitigations
    }Else{
        $Mitigations = "None"
    }

    If ($discussion.test.SeverityOverrideGuidance){
        $SeverityOverride = $discussion.test.SeverityOverrideGuidance
    }Else{
        $SeverityOverride = "None"
    }

    If ($discussion.test.PotentialImpacts){
        $PotentialImpacts = $discussion.test.PotentialImpacts
    }Else{
        $PotentialImpacts = "None"
    }

    If ($discussion.test.ThirdPartyTools){
        $ThirdPartyTools = $discussion.test.ThirdPartyTools
    }Else{
        $ThirdPartyTools = "None"
    }

    If ($discussion.test.MitigationControl){
        $MitigationControls = $discussion.test.MitigationControl
    }Else{
        $MitigationControls = "None"
    }

    $Responsibility = $discussion.test.Responsibility
    $IAControls = $discussion.test.IAControls

    "Group ID: $GroupID"
    "Group Title: $GroupTitle"
    "ID: $Id"
    "Severity: $Severity"
    "Weight: $Weight"
    "Version: $Version"
    "Rule Title: $RuleTitle"
    "Check Content: $CheckContent"
    "Vulnerability Discussion: $VulnerabilityDiscussion"
    "False Positives: $FalsePositives"
    "False Negatives: $FalseNegatives"
    "Documentable: $Documentable"
    "Mitigations: $Mitigations"
    "Severity Override: $SeverityOverride"
    "Potential Impacts: $ThirdPartyTools"
    "Third Party Tools: $MitigationControls"
    "Mitigation Controls: $Responsibility"
    "Responsibility: $Responsibility"
    "IA Controls: $IAControls"
    ""
    $Responsibility = $discussion.test.Responsibility
    $IAControls = $discussion.test.IAControls
    $rs.addnew()
    $rs.Fields.Item("GroupID").Value = $GroupID
    $rs.Fields.Item("GroupTitle").Value = $GroupTitle
    $rs.Fields.Item("RuleID").Value = $id
    $rs.Fields.Item("Severity").Value = $Severity
    $rs.Fields.Item("RuleVersion").Value = $Version
    $rs.Fields.Item("RuleTitle").Value = $RuleTitle
    $rs.Fields.Item("VunlDiscuss").Value = $VulnerabilityDiscussion
    $rs.Fields.Item("FlaseNeg").Value = $FalseNegatives
    $rs.Fields.Item("FalsePos").Value = $FalsePositives
    $rs.Fields.Item("Documentable").Value = $Documentable
    $rs.Fields.Item("Responsibility").Value = $Responsibility
    $rs.Fields.Item("IAControls").Value = $IAControls
    $rs.Fields.Item("CheckContent").Value = $CheckContent
    $rs.Fields.Item("FixText").Value = $MitigationControls
    $rs.Update()
}