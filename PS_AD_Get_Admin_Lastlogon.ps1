Get-ADGroupMember "ad-All ou-owners-gs" -Recursive | Get-ADUser -Properties * | ft sn, givenname, name, LastLogonDate, enabled, mail -AutoSize

