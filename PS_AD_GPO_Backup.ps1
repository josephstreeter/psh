$date = Get-Date -UFormat "%Y-%m-%d" 
$Path = "c:\scripts\gpobackup\$date"

new-item -itemtype directory -path $Path
Backup-GPO -All -Path $Path