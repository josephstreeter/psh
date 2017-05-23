$NetID = "OU=NetID,OU=Wisc,DC=ad,DC=wisc,DC=edu"

foreach ($DC in $(Get-ADDomainController -filter *).name) {
   $DC
   $Events = Get-WinEvent -comp $DC -FilterHashtable @{Logname='Security';Id=4625} -MaxEvents 100
   Foreach ($Event in $Events) {            
      $EventXML = [xml]$Event.ToXml()                      
      Try {[array]$Users += (Get-ADUser $EventXML.Event.EventData.Data[5].'#text' -searchbase $NetID -ErrorAction Stop).name} Catch {} 
   }
}            


$Users
$(get-date)

#$RecordID = 45523626
#Get-WinEvent -ComputerName CADSDC-CSSC-01 -FilterHashtable @{Logname='Security';Id=4625} -MaxEvents 100 | select id,leveldisplayname,recordid -ea SilentlyContinue | `
#   % {if ($_.recordid -gt $RecordID) {$_.recordid; [array]$users += $_.Id} Else {Break}}
