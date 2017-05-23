# Configure database connection
$Database = "C:\Users\joseph.streeter\OneDrive\Documents\IAMDB.accdb"
$Table = "identities"
$adOpenStatic = 3
$adLockOptimistic = 3

$conn=New-Object -com "ADODB.Connection"
$rs = New-Object -com "ADODB.Recordset"
$conn.Open("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$Database;Persist Security Info=True;")

$GivenName="Joseph"
$SN="Streeter"
$Initials="A"
$DoB="08/13/1976"
$EmplID=""
$StudentID="2222222"

Function Add-Record 
    {    
    $rs.addnew()
    $rs.Fields.Item("givenName").Value = $GivenName
    $rs.Fields.Item("sn").Value = $SN
    $rs.Fields.Item("initials").Value = $Initials
    $rs.Fields.Item("dob").Value = $DoB
    $rs.Fields.Item("emplID").Value = $EmplID
    $rs.Fields.Item("studentID").Value = $StudentID
    $rs.Update()
    }

Function Update-Record 
    {    
    #$rs.addnew()
    $rs.Fields.Item("givenName").Value = $GivenName
    $rs.Fields.Item("sn").Value = $SN
    $rs.Fields.Item("initials").Value = $Initials
    $rs.Fields.Item("dob").Value = $DoB
    $rs.Fields.Item("emplID").Value = $EmplID
    $rs.Fields.Item("studentID").Value = $StudentID
    $rs.Update()
    }

Function Connect-Database 
    {
    $rs.Open("SELECT * FROM $Table",$conn,$adOpenStatic,$adLockOptimistic)
    }

Function Close-Database 
    {
    $rs.Close()
    $conn.Close()
    }

Function Query-Database 
    {
    $rs.movefirst()
    While ($rs.eof -ne $true)
        {
        $rs.Fields.Item("givenName").Value
        $rs.Fields.Item("sn").Value
        $rs.Fields.Item("initials").Value
        $rs.Fields.Item("dob").Value
        $rs.Fields.Item("emplID").Value
        $rs.Fields.Item("studentID").Value
        $rs.MoveNext()
        }
    }