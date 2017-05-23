$Users = Get-ADUser -f * -SearchBase "OU=DisabledAccountsOrphans,DC=MATC,DC=Madison,DC=Login" -pr lastlogondate,description,info

foreach ($User in $Users)
    {
    if ($user.description)
        {
        Set-ADUser $User -add @{info=$user.description} -PassThru
        Set-ADUser $User -clear description -PassThru
        }
    }