
$strAttributeName = "edsvaTestVa" # Set the property lDAPDisplayName for the VA
$strAttributeClass = "user" # Set the object class to which the VA will apply
$strAttributeSyntax = "2.5.5.4" # Set the property attributeSyntax for the VA
$iAttributeOMSyntax = 20 # Set the property oMSyntax for the VA
$bIsAttributeStored = $true # Specify whether to store the VA in the AR Server Administration database
$bIsAttributeSindleValued = $true # Specify whether the VA is single-valued
$strVaContainerDn = "CN=Virtual Attributes,CN=Server Configuration,CN=Configuration"

function CreateVA($AttrName, $ClassSchemas, $AttrSyntax, $OMSyntax, $IsStored, $IsSingleValued){
	$objVaContainer = [ADSI]"EDMS://$strVaContainerDn"
	$objOctetString = New-Object -ComObject "AelitaEDM.EDMOctetString"
	"Creating VA $AttrName ..."
	$objNewVa = $objVaContainer.Create("edsVirtualAttribute", "CN=$AttrName")
	$objPolicyInfoList = $objNewVa.GetPolicyInfoList()
	$objOctetString.SetGuidString($objPolicyInfoList.Item("schemaIDGUID").GeneratedValue)
	
	$objNewVa.Put("edsaAttributeIsStored", [bool]$IsStored)
	$objNewVa.Put("isSingleValued", [bool]$IsSingleValued)
	$objNewVa.Put("lDAPDisplayName", [string]$AttrName)
	$objNewVa.Put("edsaClassSchemas", [string]$ClassSchemas)
	$objNewVa.Put("attributeSyntax", [string]$AttrSyntax)
	$objNewVa.Put("oMSyntax", [int]$OMSyntax)
	$objNewVa.Put("schemaIDGUID", $objOctetString.GetOctetString())
	$objNewVa.Put("attributeID", $objPolicyInfoList.Item("attributeID").GeneratedValue)

	$objNewVa.SetInfo()
    }

CreateVA -AttrName $strAttributeName -ClassSchemas $strAttributeClass -AttrSyntax $strAttributeSyntax -OMSyntax $iAttributeOMSyntax -IsStored $bIsAttributeStored -IsSingleValued $bIsAttributeSindleValued