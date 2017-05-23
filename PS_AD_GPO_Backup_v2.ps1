$date = Get-Date -UFormat "%Y-%m-%d" 
$Path = "c:\scripts\gpobackup\$date"
new-item -itemtype directory -path $Path

get-gpo -all | foreach-Object {Backup-GPO -guid $_.id -Path $Path; $_.DisplayName + "   " + $_.id + "   " + $_.Owner | Out-File -Append "$path\list.txt"}