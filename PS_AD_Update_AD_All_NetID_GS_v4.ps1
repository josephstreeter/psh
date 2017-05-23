Write-Host -ForegroundColor Yellow "Loading Modules `n"
Import-Module activedirectory

Write-Host -ForegroundColor Yellow "Set Date `n"
$date = get-date -uformat "%Y-%m-%d"
"$Date`n"

Write-Host -ForegroundColor Yellow "Set Domain `n"
$Domain = (get-addomain).Forest.toupper()
$AD_Env = (get-addomain).Name
"$Domain`n"

Try {
	Write-Host -ForegroundColor Yellow "Retrieving all NetIDs`n"
	$NetIDs = Get-ADObject -Filter * -pr altsecurityidentities, memberof -ResultPageSize 10 -searchbase "ou=NetID,ou=Wisc,DC=$AD_Env,dc=wisc,dc=edu" -ErrorAction Stop
	
	Write-Host -ForegroundColor Yellow "Retrieving all GuestNetIDs`n"
	$GuestNetIDs = Get-ADObject -Filter * -pr altsecurityidentities, memberof -ResultPageSize 10 -searchbase "ou=GuestNetID,ou=Wisc,DC=$AD_Env,dc=wisc,dc=edu" -ErrorAction Stop
	}
Catch
	{
	$Search_Error = $_.Exception.Message
	}

Write-Host -ForegroundColor Yellow "Retrieving all NetIDs that are not members of ad-all netid-gs`n"
$a=0
$NetIDs_Count = $NetIDs.count

Foreach	($NetID in $NetIDs)
	{
	If (($NetID.altsecurityidentities -like "*LOGIN.WISC.EDU") -and (-not ($NetID.memberof -eq "CN=ad-all netid-gs,OU=groups,OU=wisc,DC=$AD_Env,DC=wisc,DC=edu")))
		{
		Write-Host -ForegroundColor Green $NetID.Name
		add-ADGroupMember "ad-All NetID-gs" -Members $NetID.Name
		$a++
		}
	}

Write-Host -ForegroundColor Yellow "Retrieving all NetIDs that are not members of ad-all netid-gs`n"
$b=0
$GuestNetIDs_Count = $GuestNetIDs.count

Foreach	($GuestNetID in $GuestNetIDs)
	{
	If (($GuestNetID.altsecurityidentities -like "*LOGIN.WISC.EDU") -and (-not ($GuestNetID.memberof -eq "CN=ad-all guestnetids-gs,OU=groups,OU=wisc,DC=$AD_Env,DC=wisc,DC=edu")))
		{
		Write-Host -ForegroundColor Green $GuestNetID.Name
		add-ADGroupMember "ad-All GuestNetIDs-gs" -Members $GuestNetID.Name
		$b++
		}
	}
	
$smtpServer = "smtp.wiscmail.wisc.edu"
$mailFrom = "joseph.streeter@doit.wisc.edu"
$mailto = "joseph.streeter@doit.wisc.edu"

$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = $mailFrom
$msg.To.Add($mailTo)
$msg.Subject = "All NetID/GuestNetID Users Update - $date ($domain)"
$msg.Body = " $NetIDs_Count NetID User Objects `n $GuestNetIDs_Count Guest NetIDs `n $a NetID users were added to Group `n $b GuestNetID users were added to group `n $Search_Error"

$smtp.Send($msg)