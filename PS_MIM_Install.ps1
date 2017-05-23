import-module activedirectory
$sp = ConvertTo-SecureString "Pass@word1" –asplaintext –force
$FIMServer = $env:COMPUTERNAME

$Users = "MIMMA","MIMMA","MIMSync","MIMService","MIMSSPR","SharePoint","SqlServer","BackupAdmin"

foreach ($User in $Users)
    {
    New-ADUser –SamAccountName $User –name $User 
    Set-ADAccountPassword –identity $User –NewPassword $sp
    Set-ADUser –identity $User –Enabled 1 –PasswordNeverExpires 1
    }

$Groups = "MIMSyncAdmins","MIMSyncOperators","MIMSyncJoiners","MIMSyncBrowse","MIMSyncPasswordReset"

Foreach ($Group in $Group)
    {
    New-ADGroup –name $Group –GroupCategory Security –GroupScope Global –SamAccountName $Group
    }

Add-ADGroupMember -identity MIMSyncAdmins -Members Administrator
Add-ADGroupmember -identity MIMSyncAdmins -Members MIMService

setspn -S http/portal.ad.madison.edu AD\SharePoint
setspn -S http/portal.ad.madison.edu AD\SharePoint
setspn -S FIMService/MCAS-FIM-01.ad.madison.edu AD\MIMService
setspn -S FIMSync/MCAS-FIM-01.ad.madison.edu AD\MIMSync