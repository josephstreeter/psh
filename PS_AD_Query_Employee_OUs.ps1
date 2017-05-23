$date = ((Get-Date).AddDays(-5)).Date

$OUs = "OU=Admin,OU=Facstaff,DC=MATC,DC=Madison,DC=Login",
"OU=Faculty,OU=Facstaff,DC=MATC,DC=Madison,DC=Login",
"OU=Staff,OU=Facstaff,DC=MATC,DC=Madison,DC=Login",
"OU=TechServices,OU=FacStaff,DC=MATC,DC=Madison,DC=Login",
"OU=NonEmployee,DC=MATC,DC=Madison,DC=Login"
"OU=UndeterminedUser,DC=MATC,DC=Madison,DC=Login"

foreach ($OU in $OUs)
    {
    Get-ADUser -Filter {whenCreated -ge $date} -SearchBase $OU -pr whencreated,carlicense,employeeID,employeeType | ft name,samaccountName,employeeID,employeeType,whencreated,carlicense
    }