Function Get-Location($Origin,$LoginDisabled,$saladminplan,$departmentNumber,$jobcode)
    {
    $Loc = "OU=UndeterminedUsers"
    $disabled = $LoginDisabled
    switch ($Origin)
	    {
	    "R" {$Loc = "OU=EmailOnly"}	
        "Q" {$Loc = "OU=NonEmployee"}
        "S" {}
        "X" {
            if ($disabled -eq "TRUE" )
                {
                $Loc = "OU=Student,OU=DisabledAccounts"
                }
                else
                {
                $Loc = "OU=Users,OU=Student"
                }
            }
        "T" {
            if ($saladminplan.length -gt 0 )
                {
                if ( $disabled -eq "TRUE" )
                    {
                    $Loc = "OU=Staff,OU=DisabledAccounts"
                    }
                }
            }
	    "N" {
            if ($disabled -eq "TRUE" )
                {
                $Loc = "OU=Student,OU=DisabledAccounts"
                }
                else
                {
                $Loc = "OU=Users,OU=Student"
                }
            }		
	    "E" {}
	    "Z" {
            if ( $disabled -eq "TRUE" )
                {
                $Loc = "OU=Staff,OU=DisabledAccounts"
                }
                else
                {
                switch ($saladminplan)
                    {
                    "M05" {$Loc = "OU=Admin,OU=FacStaff"}
		            "M07" {$Loc = "OU=Admin,OU=FacStaff"}
		            "M03" {}
                    "M04" {
		                if (($departmentNumber -eq "907") -or ($departmentNumber -eq "735") -or ($departmentNumber -eq "903") -or 
		                    ($departmentNumber -eq "908") -or ($departmentNumber -eq "906") -or ($departmentNumber -eq "905") -or 
		                    ($departmentNumber -eq "904") -or ($departmentNumber -eq "732") -or ($departmentNumber -eq "909") -or
		                    ($departmentNumber -eq "919"))
		                        {
	                            $Loc = "OU=TechServices,OU=FacStaff"
	                            }
	                            else
		                        {
		                        $Loc = "OU=Staff,OU=FacStaff"
	                            }
                            }
                    
                    }
                 }
             }  
        default {
	             if (($JobCode -eq "M003") -or ($JobCode -eq "M005") -or ($JobCode -eq "M006") -or ($JobCode -eq "M011") -or ($JobCode -eq "M014"))
                    {
		            $Loc = "OU=Faculty,OU=FacStaff"
	                }
	                elseif ($JobCode -eq "M099")
		            {
		            $Loc = "OU=Staff,OU=FacStaff"
	                }
			    }
	    }
    Return $Loc
    }