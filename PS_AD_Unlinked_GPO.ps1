Import-Module GroupPolicy

Get-GPO -All | %{If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ){Write-Host $_.DisplayName}}