$adOpenStatic = 3
$adLockOptimistic = 3

$conn=New-Object -com "ADODB.Connection"
$rs=New-Object -com "ADODB.Recordset"
$conn.Open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\users\joseph.streeter\desktop\STIG.accdb;Persist Security Info=True;')

$rs.Open("SELECT * FROM WS2008R2",$conn,$adOpenStatic,$adLockOptimistic)

$rs.Fields.Item("GroupID").value
$rs.Fields.Item("GroupTitle").value
$rs.Fields.Item("RuleID").value
$rs.Fields.Item("Severity").value
$rs.Fields.Item("RuleVersion").value
$rs.Fields.Item("RuleTitle").value
$rs.Fields.Item("VunlDiscuss").value
$rs.Fields.Item("FlaseNeg").value
$rs.Fields.Item("FalsePos").value
$rs.Fields.Item("Documentable").value
$rs.Fields.Item("Responsibility").value
$rs.Fields.Item("IAControls").value
$rs.Fields.Item("CheckContent").value
$rs.Fields.Item("FixText").value

$conn.Close
$rs.Close