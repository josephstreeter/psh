function Get-WIAStatusValue($value)
    {
    switch -exact ($value)
        {
        0 {"NotStarted"}
        1 {"InProgress"}
        2 {"Succeeded"}
        3 {"SucceededWithErrors"}
        4 {"Failed"}
        5 {"Aborted"}
        }
    }

$needsReboot = $false
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

Write-Host " - Searching for Updates"
$SearchResult = $UpdateSearcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0")
Write-Host " - Found [$($SearchResult.Updates.count)] Updates to Download and install"
Write-Host

$Results=@()
foreach ($Update in $SearchResult.Updates)
    {
    $Results+=New-Object psobject -Property @{
        "Title"=$Results.Title
        "Description"=$Results.Description
        "EULAAccepted"=$Results.EulaAccepted
        "Downloaded"=$Results.IsDownloaded
        "Reboot"=$Results.RebootRequired
        "Present"=$Results.IsPresent
        }
    }

$Results | ft -AutoSize
<#
foreach($Update in $SearchResult.Updates)
    {
    # Add Update to Collection
    $UpdatesCollection = New-Object -ComObject Microsoft.Update.UpdateColl
    if ( $Update.EulaAccepted -eq 0 ) 
        { 
        $Update.AcceptEula() 
        }
    $UpdatesCollection.Add($Update) | Out-Null
    }
$UpdatesCollection

    # Download
    Write-Host " + Downloading Update $($Update.Title)"
    $UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()
    $UpdatesDownloader.Updates = $UpdatesCollection
    $DownloadResult = $UpdatesDownloader.Download()
    $Message = " - Download {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
    Write-Host $message

    # Install
    Write-Host " - Installing Update"
    $UpdatesInstaller = $UpdateSession.CreateUpdateInstaller()
    $UpdatesInstaller.Updates = $UpdatesCollection
    $InstallResult = $UpdatesInstaller.Install()
    $Message = " - Install {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
    Write-Host $message
    Write-Host
    $needsReboot = $installResult.rebootRequired
    }
    #>

if($needsReboot)
    {
    Write-Host "restart-computer"
    }
