Function Enumerate-Folders()
    {
    $Results = Get-ChildItem "\\naf01b\ENShare2\Infrastructure" -Recurse
    Return $Results
    }

Function Enumerate-ACL($Folder)
    {
    $Results = Get-ACL $Folder.FullName
    Return $Results
    }

$Folders = Enumerate-Folders "\\naf01b\ENShare2\Infrastructure"
$Report=@()

foreach ($Folder in $Folders)
    {
    if ($Folder.Mode -like "d*")
        {        
        $ACL = Enumerate-ACL $Folder
        foreach ($ACE in $ACL.access)
            {
            $Report+=New-Object PSObject -Property @{
                "Path"=$Folder.FullName
                "Owner"=$ACL.Owner
                "Group"=$ACL.Group
                "Rights"=$ACE.FileSystemRights
                "ID"=$ACE.IdentityReference
                }
            }
        }
    }
$Report | ft path,owner,id