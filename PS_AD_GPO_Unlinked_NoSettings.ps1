Import-Module grouppolicy

Write-Host "`nUnlinked GPOs`n"
$allGPOs = Get-GPO -All | sort DisplayName
ForEach ($gpo in $allGPOs) {
    $xml = [xml](Get-GPOReport $gpo.Id xml)
    If (!$xml.GPO.LinksTo) {
        $gpo.DisplayName
        }
    }

Write-Host "`nGPOs with no settings`n"
$allGPOs = Get-GPO -All | sort DisplayName
ForEach ($gpo in $allGPOs) {
    $xml = [xml](Get-GPOReport $gpo.Id xml)
    If ($xml.GPO.LinksTo) {
        If (!$xml.GPO.Computer.ExtensionData -and !$xml.GPO.User.ExtensionData) {
            $gpo.DisplayName
            }
        }
    }
