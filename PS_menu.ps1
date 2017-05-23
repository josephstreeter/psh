Function Get-Menu {
	Write-Host "***********************"
	Write-Host "*** CADS Management ***"
	Write-Host "***********************"
	Write-Host "Choose your environment."
	Write-Host "1. Reset Password"
	Write-Host "2. Test"
	Write-Host "3. Development"
	Write-Host "4. Exit"
	Write-Host " "
	$a = Read-Host "Select 1-3: "
	


	switch ($a) 
	    { 
	        1 {clear-host; reset-password} 
	        2 {clear-host; get-test                } 
	        3 {clear-host; get-dev          } 
	        4 {Break                                                  } 
	        default {"** The selection could not be determined **"}
	    }

	}

Function Reset-Password {
	Write-Host "****  Password Reset  ****"
	$User = Read-Host "Enter Username"
	Get-ADUser -f {cn -eq $user} | fl name, description
	$Password1 = Read-Host "Enter New Password: " -AsSecureString
	$Password2 = Read-Host "Confirm New Password: " -AsSecureString
	If ($Password1 -ne $Password2) {"Passwords do not Match"}
	Else {"Passwords Match"}
	}

Function Get-Test {
	Write-Host "Test Tasks."
	Write-Host "1. Create New"
	Write-Host "2. Delete Existing"
	Write-Host "3. Do Nothing"
	Write-Host " "
	$a = Read-Host "Select 1-3: "
	


	switch ($a) 
	    { 
	        1 {clear-host; "** New Environment **`n`n"; Get-test        } 
	        2 {clear-host; "** Delete environment **`n`n"; Get-test              } 
	        3 {clear-host; "** Nothing **`n`n"; Get-menu       } 
	        default {"** The selection could not be determined **`n`n"; Get-menu }
	    }

	}

Function Get-Dev {
	Write-Host "Dev Tasks."
	Write-Host "1. Create New"
	Write-Host "2. Delete Existing"
	Write-Host "3. Do Nothing"
	Write-Host " "
	$a = Read-Host "Select 1-3: "
	


	switch ($a) 
	    { 
	        1 {clear-host; "** New Environment **`n`n"; Get-dev       } 
	        2 {clear-host; "** Delete environment **`n`n"; Get-dev               } 
	        3 {clear-host; "** Nothing **`n`n"; Get-menu       } 
	        default {"** The selection could not be determined **`n`n"; Get-menu }
	    }

	}

clear-host
get-menu