$Domain = (get-addomain).Forest.toupper()
$RootDSE = (Get-ADRootDSE).defaultnamingcontext
$date = get-date -uformat "%Y-%m-%d"

$AllNetID = "CN=ad-all netid-gs,OU=groups,OU=wisc,$RootDSE"
$NetIDList = ".\netids_added.txt"

$base = New-Object DirectoryServices.DirectoryEntry("LDAP://ou=NetID,ou=Wisc,dc=ad,dc=wisc,dc=edu")
$searcher =  New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot  = $base
$Searcher.PageSize  = 1000
$Searcher.SearchScope  = "subtree"

# Filter on user members of the specified group.
$Searcher.Filter = "(&(objectCategory=person)(objectClass=user)(altsecurityidentities=*LOGIN.WISC.EDU)(name=*))"

# Specify attributes to retrieve.
$Searcher.PropertiesToLoad.Add("Name") > $Null
$Searcher.PropertiesToLoad.Add("altsecurityidentities") > $Null
$Searcher.PropertiesToLoad.Add("Memberof") > $Null

$Results =  $Searcher.FindAll()
$count = $Results.count

ForEach($Result in $Results) {
    [string]$Name = $Result.Properties.Item("Name")
    [string]$AltSec = $Result.Properties.Item("altsecurityidentities")
    [string]$Memberof = $Result.Properties.Item("Memberof")

    if (-not ($Memberof -like "*CN=ad-all netid-gs,OU=groups,OU=wisc,DC=ad,DC=wisc,DC=edu*")){
        Get-ADUser $Name -pr whencreated, memberof | select name, whencreated, memberof | Out-File -Append $Attachments
        }
    }
$To = "Campus Active Directory <activedirectory@doit.wisc.edu>" 
$From = "Campus Active Directory <activedirectory@doit.wisc.edu>" 
$Subject = "All NetID/GuestNetID Users Update - $date ($domain)"
$Attachments = ".\NetIDs.txt"
$SmtpServer = "smtp.wiscmail.wisc.edu"
$Body = " $count NetIDs "

Send-MailMessage -To $To -From $From  -Subject $Subject -Body $Body -SmtpServer $SmtpServer -BodyAsHtml -Attachments $Attachments

Remove-Item $Attachments  