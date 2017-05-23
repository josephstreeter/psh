$adOpenStatic = 3
$adLockOptimistic = 3

$conn=New-Object -com "ADODB.Connection"
$rs=New-Object -com "ADODB.Recordset"
$conn.Open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\users\joseph.streeter\desktop\STIG.accdb;Persist Security Info=True;')

$rs.Open("SELECT * FROM WS2008R2",$conn,$adOpenStatic,$adLockOptimistic)

$rs.addnew()
$rs.Fields.Item("GroupID").Value = "TEST"
$rs.Fields.Item("GroupTitle").Value = "TEST"
$rs.Fields.Item("RuleID").Value = "TEST"
$rs.Fields.Item("Severity").Value = "TEST"
$rs.Fields.Item("RuleVersion").Value = "TEST"
$rs.Fields.Item("RuleTitle").Value = "TEST"
$rs.Fields.Item("VunlDiscuss").Value = "TEST"
$rs.Fields.Item("FlaseNeg").Value = "TEST"
$rs.Fields.Item("FalsePos").Value = "TEST"
$rs.Fields.Item("Documentable").Value = "TEST"
$rs.Fields.Item("Responsibility").Value = "TEST"
$rs.Fields.Item("IAControls").Value = "TEST"
$rs.Fields.Item("CheckContent").Value = "TEST"
$rs.Fields.Item("FixText").Value = "TEST"

$rs.Update()

$rs.Close()
$conn.Close()