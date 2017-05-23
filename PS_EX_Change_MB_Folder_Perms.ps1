$Report = "c:\scripts\Report-$(Get-Date -Format o | foreach {$_ -replace ":", "."}).txt"   # Create path to report file
Get-Date | out-file $Report                                                                # Create new report file

$Folders = Get-MailboxFolderStatistics budgetoffice                                        # Enumerate mailbox folders

Foreach ($Folder in $Folders)
    {
    $FolderID = ($Folder.identity).tostring().replace("budgetoffice","budgetoffice@madisoncollege.edu:")      # Format folder id for later use
    $Perms = Get-MailboxfolderPermission $FolderID                                                            # Enumnerate current permissions on the folder
    Foreach ($Perm in $Perms)
        {
        If ((($Perm).user.ADRecipient -eq "Richard C Graves") -and (($Perm).AccessRights[0] -eq "PublishingEditor")) # Select the permissions to be changed
            {
            $Perm | select FolderName,User,AccessRights,Identity | out-file c:\scripts\Report.txt -append     # Add current permissions to report
            Set-MailboxFolderPermission -Identity $FolderID -User "Richard C Graves" -AccessRights None       # Set new permissions
            }
        }
    }