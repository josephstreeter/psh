Connect-QADService -Proxy

$ContainerName = "Restrict Policies"
$POName = "TestPolicy"

Function Create-PolicyContainer {
    New-QADObject `
        -ParentContainer "CN=Administration,CN=Policies,CN=Configuration" `
        -Name $ContainerName `
        -Type "edsPolicyObjectsContainer" `
        -Proxy
    }

Function Create-PolicyObject {
    New-QADObject `
        -ParentContainer "CN=Administration,CN=Policies,CN=Configuration" `
        -Name $PoName `
        -Type "edsPolicyObject" `
        -Proxy 
    }