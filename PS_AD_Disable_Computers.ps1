Import-Module ActiveDirectory
If (-not $?) { "Failed to import AD module!" ; exit }
$Disabled = 0
$Deleted = 0
$Computers = get-adcomputer -f * -pr comment -searchbase (get-ADDomain).ComputersContainer
foreach ($Computer in $Computers)
  {
    If (-not $Computer.Comment)
    {
    set-adComputer -identity $Computer.name -Enable $False -replace @{comment = (Get-Date).ToShortDateString()}
    $Disabled++
    }
  Else
    {
    $d = $Computer.comment
    If (((Get-Date)-(get-date $d)).days -ge 14)
    {
      Remove-ADComputer -Identity $Computer.name -Confirm:$False
      $Deleted++
    }
  }
}
"$Disabled Computers disabled"
"$Deleted Computers deleted"
