Param(
    $firstName = "Joseph",
    $LastName = "Hanson",
    $MI = "D"
    )

BEGIN 
    {
    Import-Module ActiveDirectory
    }

PROCESS 
    {
    Function Check-UserName($UserName)
        {
        if (Get-ADUser -f {samaccountname -eq $UserName} -ea 0) 
            {
            Return $False
            }
            Else
            {
            Return $True
            }
        }

    $UserNames = @()
    $UserNames += $firstName.substring(0,1) + $LastName
    $UserNames += $firstName.substring(0,1) + $MI + $LastName
  
    $i=1
    do
    {
    $UserNames += $firstName.substring(0,1) + $LastName + $i
    
    $i++    
    }
    while ($i -lt 99)
    
    foreach ($UserName in $UserNames)
        {
        if (Check-UserName $UserName -eq "True")
            {
            $UserName
            Break
            }
        }
    }

END 
    {
    Clear-Variable UserNames
    }



