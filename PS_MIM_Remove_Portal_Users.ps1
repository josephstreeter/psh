
#----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' "
 set-variable -name ADMINGUID -value "7fb2b853-24f0-4498-9534-4e10589723c4"
 set-variable -name SYNCGUID -value "fb89aefa-5ea1-47f1-8890-abe7797d6497"
#----------------------------------------------------------------------------------------------------------
 
 function DeleteObject
 {
    PARAM($objectType, $objectId)
    END
    {
       $importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
       $importObject.ObjectType = $objectType
       $importObject.TargetObjectIdentifier = $objectId
       $importObject.SourceObjectIdentifier = $objectId
       $importObject.State = 2 
       $importObject | Import-FIMConfig -uri $URI
     } 
 }
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $allobjects = export-fimconfig -uri $URI `
                                –onlyBaseResources `
                                -customconfig "/Person"
 $allobjects | Foreach-Object {
    $objectId = (($_.ResourceManagementObject.ObjectIdentifier).split(":"))[2]
    if($objectID -eq $ADMINGUID)
    {write-host "Administrator NOT deleted"}
    elseif($objectID -eq $SYNCGUID)
    {write-host "Built-in Synchronization Account NOT deleted"}

    else { 
      DeleteObject -objectType "Person" `
                  -objectId $objectId
      write-host "`nObject deleted`n"}
 } 
 

 
