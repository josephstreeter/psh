# https://fimpowershellmodule.codeplex.com/documentation?version=37

###
### Create the Set: '!MC Users Active'
###
$setXPathFilter = @"
<Filter 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    Dialect="http://schemas.microsoft.com/2006/11/XPathFilterDialect" 
    xmlns="http://schemas.xmlsoap.org/ws/2004/09/enumeration"
    >
/Person[(EmployeeStatus = 'A') and ((EmployeeType = 'A') or (EmployeeType = 'I') or (EmployeeType = 'C') or (EmployeeType = 'E') or (EmployeeType = 'F') or (EmployeeType = 'S'))]</Filter>
"@
New-FimImportObject -objectType 'Set' -State Create -Changes @{
	DisplayName = "!!MC Users Active"
	Filter      = $setXPathFilter
} -ApplyNow

###
### Create the Set: '!MC Users Inactive'
###
$setXPathFilter = @"
<Filter 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    Dialect="http://schemas.microsoft.com/2006/11/XPathFilterDialect" 
    xmlns="http://schemas.xmlsoap.org/ws/2004/09/enumeration"
    >
/Person[(EmployeeStatus = 'D') and ((EmployeeType = 'A') or (EmployeeType = 'I') or (EmployeeType = 'C') or (EmployeeType = 'E') or (EmployeeType = 'F') or (EmployeeType = 'S'))]</Filter>
"@
New-FimImportObject -objectType 'Set' -State Create -Changes @{
	DisplayName = "!!MC Users Inactive"
	Filter      = $setXPathFilter
} -ApplyNow