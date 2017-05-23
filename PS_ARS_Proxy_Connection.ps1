$DeptCode = "DEPT"
$Name = "TUser"
$FirstName = "Test"
$LastName = "User"
$Initials = "A"
$DisplayName = "User, Test"
$Description = "OU Owner"
$Email = "test.user@wisc.edu"
$City = "Madison"
$Company = "UW-Madison"
$Department = "DoIT"
$PhoneNumber = "608.220.4956"

If (!(Get-PSSnapin quest.activeroles.admanagement -ea SilentlyContinue)){
    add-pssnapin quest.activeroles.admanagement
    }

Try {
    #Connect-QADService `
    #    -Service "cadsas-ars-01.adtest.wisc.edu" `
    #    -Credential $(Get-Credential) `
    #    -Proxy `
    #    -ErrorAction Stop

    Connect-QADService `
        -Service "cadsas-qars-03.adtest.wisc.edu" `
        -Proxy `
        -ErrorAction Stop
    }
Catch {
    "Error";break
    }

$Domains = @(
    "DC=ad,DC=doit,DC=wisc,DC=edu"
    "DC=ad,DC=wisc,DC=edu"
    "DC=adtest,DC=wisc,DC=edu"
    )

Function New-Admin {
    ForEach ($Domain in $Domains){
        New-QADUser `
            -ParentContainer "OU=Users,OU=ENT,OU=LAB,$Domain" `
            -Name $Name `
            -SamAccountName $Name `
            -FirstName $FirstName `
            -LastName $LastName `
            -Initials $Initials `
            -DisplayName $DisplayName `
            -Description $Description `
            -UserPassword $(ConvertTo-SecureString -AsPlainText "Pa!!Word123456" -Force ) `
            -Email $Email `
            -City $City `
            -Company $Company `
            -Department $Department `
            -PhoneNumber $PhoneNumber `
            -Proxy
    
        Add-QADGroupMember `
            -Identity "CN=CADS-GS-$DeptCode-OU-Owners,OU=Groups,OU=ENT,OU=LAB,$Domain" `
            -Member "CN=$Name,OU=Users,OU=ENT,OU=LAB,$Domain" `
            -Proxy
        } 
    }

Function New-Service {
    ForEach ($Domain in $Domains){
        New-QADObject `
            -ParentContainer "OU=OrgUnits,OU=Lab,$Domain" `
            -Name $DeptCode `
            -Description $Description `
            -Type OrganizationalUnit

        New-QADGroup `
            -ParentContainer "OU=Groups,OU=ENT,OU=LAB,$Domain" `
            -Name "CADS-GS-$DeptCode-OU-Owners" `
            -GroupType Security `
            -GroupScope Global
        }
    }


New-Service
New-Admin 