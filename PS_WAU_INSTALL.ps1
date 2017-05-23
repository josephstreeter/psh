function Get-WUAU($value) {
switch -exact ($value){
    0 {"NotStarted"}
    1 {"InProgress"}
    2 {"Succeeded"}
    3 {"SucceededWithErrors"}
    4 {"Failed"}
    5 {"Aborted"}
    }
}

Function Email-Result {
$SysName = (Get-WmiObject -class Win32_ComputerSystem).name
$date = get-date -uformat "%Y-%m-%d"
$To = "Streeter, Joseph A <joseph.streeter@doit.wisc.edu>" 
$From = "Streeter, Joseph A <joseph.streeter76@gmail.com>"
#$From = "Streeter, Joseph A <joseph.streeter@doit.wisc.edu>"  
$Subject = "WAU Install for $SysName ($date)"
$SmtpServer = "www.joseph-streeter.com"
$SmtpServer = "smtp.wiscmail.wisc.edu"
$Port = 587
$Body = "$SysName has installed updates"

Send-MailMessage `
    -To $To `
    -From $From  `
    -Subject $Subject `
    -Body $Body `
    -SmtpServer $SmtpServer `
    -Attachments $Status
}

$Status = ".\status.txt"
$RebootHost = $false
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()

Write-Host " - Searching for Updates"

$Result = $Searcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0")
$UpdateCount = $($Result.Updates.count)
Write-Host " - Found $UpdateCount Updates to Download and install `n"
" - Found $UpdateCount Updates to Download and install `n" | Out-File $Status
$Result.Updates | select title | Out-File -Append $Status

foreach($Update in $Result.Updates) {
    $Collection = New-Object -ComObject Microsoft.Update.UpdateColl
    if ( $Update.EulaAccepted -eq 0 ) { $Update.AcceptEula() }
    $Collection.Add($Update) | out-null

    Write-Host " + Downloading Update $($Update.Title)"
    " + Downloading Update $($Update.Title)" | Out-File -Append $Status
    $UpdatesDownloader = $Session.CreateUpdateDownloader()
    $UpdatesDownloader.Updates = $Collection
    $DownloadResult = $UpdatesDownloader.Download()
    $Message = "   - Download {0}" -f (Get-WUAU $DownloadResult.ResultCode)
    Write-Host $message
    "$Message" | Out-File -Append $Status

    Write-Host "   - Installing Update"
    "   - Installing Update" | Out-File -Append $Status
    $UpdatesInstaller = $Session.CreateUpdateInstaller()
    $UpdatesInstaller.Updates = $Collection
    $InstallResult = $UpdatesInstaller.Install()
    $Message = "   - Install {0}" -f (Get-WUAU $DownloadResult.ResultCode)
    Write-Host $message
    Write-Host
    "$Message `n" | Out-File -Append $Status
    $RebootHost = $installResult.rebootRequired
}

Email-Result

if($RebootHost){
    Restart-Computer
}