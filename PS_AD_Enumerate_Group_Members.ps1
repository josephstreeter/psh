Import-Module ActiveDirectory

$members = Get-ADGroupMember "ad-All ou-owners-gs"

foreach ($user in $members) 
{
if ($user.ObjectClass -eq "user")
   {
    get-adUser $user.name
   }
}