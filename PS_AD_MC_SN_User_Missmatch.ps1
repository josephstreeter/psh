Function Get-ADInfo
    {
    $DNs = "OU=Admin,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","OU=Staff,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","OU=Faculty,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","OU=TechServices,OU=FacStaff,DC=MATC,DC=Madison,DC=Login","OU=Users,OU=Student,DC=MATC,DC=Madison,DC=Login"

foreach ($DN in $DNs)
    {
    "$DN`n"
    $users = Get-ADuser -f * -SearchBase $DN -pr employeeid,mail
    $PropArray = @()
    foreach ($user in $users)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name username -value $user.SamAccountName
        $Prop | Add-Member -type NoteProperty -name upnprefix -value $user.UserPrincipalName
        $Prop | Add-Member -type NoteProperty -name alias -value $user.mail
        $PropArray += $Prop
        }
    }
    $PropArray | ft -AutoSize
    }


function Get-SNUsers 
    {
    $users = Import-Csv 'C:\Scripts\users 12-7.csv'
    $PropArray = @()
    foreach ($user in $users)
        {
        $ADUser = ""
        $ADUser = get-aduser $user.username -pr mail | select sAMAccountName,mail,distinguishedname -ErrorAction 0
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name SNUserName -value $ADUser.samaccountname
        $Prop | Add-Member -type NoteProperty -name ADUserName -value $User.username
        $Prop | Add-Member -type NoteProperty -name ADAlias -value $ADUser.mail
        $Prop | Add-Member -type NoteProperty -name SNAlias -value $User.email
        $Prop | Add-Member -type NoteProperty -name ADDistinguishedName -value $ADUser.distinguishedName
        $PropArray += $Prop
        }
    $PropArray | ConvertTo-Csv | Out-File C:\Scripts\SN_WTF.csv 
    }

Function get-mismatch 
    {foreach ($item in $PropArray)
        {
        if ($item.alias)
            {
            if ($item.username -ne $item.alias.Split("@")[0])
                {
                $item 
                }
            }
        }
    } 

get-mismatch | ft -AutoSize
Get-SNUsers 
Get-ADInfo