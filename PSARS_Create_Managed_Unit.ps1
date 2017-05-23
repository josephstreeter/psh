$ContainerName = "DOIT Users"    # Name of MU Container
$MUName = "DOIT ALL SYSTEM USERS"  # Name of MU


Function Create-Container {
    New-QADObject `
        -Name $ContainerName `
        -ParentContainer "CN=Managed Units,CN=Configuration" `
        -Type "edsManagedUnitsContainer" `
        -proxy
    }

Function Create-ManagedUnit {
    New-QADObject `
        -Name $MUName `
        -ParentContainer "CN=Managed Units,CN=Configuration" `
        -Type "edsManagedUnit" `
        -proxy
    }

Function Add-ManagedUnitRules {
    $MU = "EDMS://CN=$MUName,cn=Department 1,CN=Managed Units,CN=Configuration"
    $muObject = [ADSI] $MU
    $RuleCollection = $muObject.MembershipRuleCollection

    $rule1 = New-Object -ComObject "EDSIManagedUnitCondition"
    $rule1.Base = "EDMS://CN=Users,DC=mycompany,DC=com"
    $rule1.Filter = "(|(objectClass=user)(objectClass=computer))"
    $rule1.Type = 1 

    # Add the newly created membership rule to the rule collection
    $RuleCollection.Add($rule1)
    $muObject.SetInfo()
    "Rule added"
    
    # Disable GUID lookup
    $RuleCollection.GuidLookupMustBePerformed = $false
    # Reload the attribute values for Managed Unit after disabling the GUID lookup
    $muObject.GetInfo()
    # Create a new Include by Query rule
    $rule2 = New-Object -ComObject "EDSIManagedUnitCondition"
    # Set the GUID for a container object where the search will start
    $rule2.BaseGuid = "26BD581B-7B7B-4605-A07B-EF42535E821D"
    $rule2.Filter = "(|(objectClass=user)(objectClass=group))"
    $rule2.Type = 1
    # Add the newly created membership rule to the rule collection
    $RuleCollection.Add($rule2)
    $muObject.SetInfo()
    "Rule added"
    }

Function Get-ManagedUnitResults {
    $mu = Get-QADObject $MU -proxy
    $users = $mu.Item("edsaMember") | Get-QADUser
    "Managed Unit: $MU includes the following users:" | Out-File -FilePath $OutputFile -Encoding "utf8"
    $users | %{ $_.DN |Out-File -Encoding "utf8" -FilePath $OutputFile -Append }
    "The file $OutputFile was created."
    }

$cred = Get-Credential
Try {Connect-QADService -Service CADSAS-ARS-01.adtest.wisc.edu -Proxy -Credential $cred;cls}
Catch {"Cannot Connect";Break}

Create-Container
Create-ManagedUnit
#Add-ManagedUnitRules
#Get-ManagedUnitResults