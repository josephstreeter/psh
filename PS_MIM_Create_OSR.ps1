$RelationshipCriteria = @(
'<conditions><condition>'
'<ilmAttribute>employeeID</ilmAttribute>'
'<csAttribute>employeeID</csAttribute>'
'</condition>'
'<condition>'
'<ilmAttribute>employeeType</ilmAttribute>'
'<csAttribute>employeeType</csAttribute>'
'</condition>'
'</conditions>') `

$msidmOutboundScopingFilters = '<scoping><scope><csAttribute>employeeStatus</csAttribute><csOperator>EQUAL</csOperator><csValue>Active</csValue></scope></scoping>' `

$InitialFlow = @(
'<export-flow allows-null="false"><src></src><dest>unicodePwd</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg>"Pass"</arg><arg><fn id="RandomNum" isCustomExpression="true"><arg>1000</arg><arg>9999</arg></fn></arg><arg>"Word_!"</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr></src><dest>sAMAccountName</dest><scoping></scoping><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr></src><dest>userPrincipalName</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></arg><arg>"@matc.ts.test"</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr><attr>employeeType</attr></src><dest>dn</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg>"CN="</arg><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></arg><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"E"</arg></fn></arg><arg>",OU=Staff,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"I"</arg></fn></arg><arg>",OU=TechServices,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"C"</arg></fn></arg><arg>",OU=Staff,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"F"</arg></fn></arg><arg>",OU=Faculty,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"A"</arg></fn></arg><arg>",OU=Admin,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"Q"</arg></fn></arg><arg>",OU=NonEmployee"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"S"</arg></fn></arg><arg>",OU=Users,OU=Student"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"T"</arg></fn></arg><arg>",OU=Staff,OU=DisabledAccounts"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"R"</arg></fn></arg><arg>",OU=EmailOnly"</arg><arg>",OU=UndeterminedUsers"</arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg><arg>",DC=MATC,DC=TS,DC=TEST"</arg></fn></export-flow>'
'<export-flow allows-null="false"><src>66048</src><dest>userAccountControl</dest><scoping></scoping></export-flow>'
)
$PersistentFlow = @(
'<export-flow allows-null="false"><src><attr>employeeType</attr></src><dest>employeeType</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>city</attr></src><dest>l</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>postalCode</attr></src><dest>postalCode</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>st</attr></src><dest>st</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>firstName</attr></src><dest>givenName</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>lastName</attr></src><dest>sn</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>employeeID</attr></src><dest>employeeID</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>address</attr></src><dest>streetAddress</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>jobTitle</attr></src><dest>title</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>employeeNumber</attr></src><dest>employeeNumber</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>officePhone</attr></src><dest>telephoneNumber</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>officeLocation</attr></src><dest>physicalDeliveryOfficeName</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr></src><dest>sAMAccountName</dest><scoping></scoping><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr></src><dest>userPrincipalName</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></arg><arg>"@matc.ts.test"</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>accountName</attr><attr>employeeID</attr><attr>employeeType</attr></src><dest>dn</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg>"CN="</arg><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="IsPresent" isCustomExpression="false"><arg>accountName</arg></fn></arg><arg>accountName</arg><arg>employeeID</arg></fn></arg><arg><fn id="IIF" isCustomExpression="true"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"E"</arg></fn></arg><arg>",OU=Staff,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"I"</arg></fn></arg><arg>",OU=TechServices,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"C"</arg></fn></arg><arg>",OU=Staff,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"F"</arg></fn></arg><arg>",OU=Faculty,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"A"</arg></fn></arg><arg>",OU=Admin,OU=FacStaff"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"Q"</arg></fn></arg><arg>",OU=NonEmployee"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"S"</arg></fn></arg><arg>",OU=Users,OU=Student"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"T"</arg></fn></arg><arg>",OU=Staff,OU=DisabledAccounts"</arg><arg><fn id="IIF" isCustomExpression="false"><arg><fn id="Eq" isCustomExpression="false"><arg>employeeType</arg><arg>"R"</arg></fn></arg><arg>",OU=EmailOnly"</arg><arg>",OU=UndeterminedUsers"</arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg></fn></arg><arg>",DC=MATC,DC=TS,DC=TEST"</arg></fn></export-flow>'
'<export-flow allows-null="false"><src>66048</src><dest>userAccountControl</dest><scoping></scoping></export-flow>'
'<export-flow allows-null="true"><src><attr>middleName</attr></src><dest>initials</dest><scoping></scoping><fn id="Left" isCustomExpression="true"><arg>middleName</arg><arg>1</arg></fn></export-flow>'
'<export-flow allows-null="false"><src><attr>lastName</attr><attr>firstName</attr></src><dest>displayName</dest><scoping></scoping><fn id="+" isCustomExpression="false"><arg>lastName</arg><arg>", "</arg><arg>firstName</arg></fn></export-flow>'
 )

New-FimSynchronizationRule `
    -DisplayName '!AD-Users-Active-Outbound' `
    -Description 'Active Directory Outbound Sync Rules for Active users' `
    -ManagementAgentID ('ma-data','DisplayName','ADMA-Test') `
    -ConnectedObjectType 'user' `
    -ILMObjectType 'person' `
    -DisconnectConnectedSystemObject $False `
    -CreateConnectedSystemObject $true `
    -CreateILMObject $False `
    -FlowType '1' `
    -Precedence '1' `
    -RelationshipCriteria $RelationshipCriteria `
    -msidmOutboundIsFilterBased $False `
    -msidmOutboundScopingFilters $msidmOutboundScopingFilters `
    -InitialFlow $InitialFlow `
	-PersistentFlow $PersistentFlow