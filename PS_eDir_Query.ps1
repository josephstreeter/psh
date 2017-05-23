Param(
    [string]$UserName,
    [string]$EmployeeID,
    [string]$EmployeeStatus,
    [string]$EmployeeType,
    [string]$Disabled,
    [string]$Origin
    )

    #$Uid = Read-Host "Enter LDAP Username"
    #$pwd = Read-Host "Enter LDAP Password" -AsSecureString

if (-not($UserName)) {$UserName="jst*"}
if (-not($EmployeeID)) {$EmployeeID="*"}
if (-not($EmployeeType)) {$EmployeeType="*"}
if (-not($EmployeeStatus)) {$EmployeeStatus="*"}
if (-not($Disabled)) {$Disabled="*"}
if (-not($Origin)) {$Origin="*"}#>

#Load Support Modules and Assemblies
#Import-Module ActiveDirectory
#Import-Module SQLPS -DisableNameChecking
Add-Type -AssemblyName System.DirectoryServices

#Setup eDirectory Connection Variables
$eDirPath = "LDAP://10.39.0.206:389/o=matc"
$eDirUser = "cn=$UID,ou=users,o=matc"
$eDirPWD  = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($pwd))
$eDIrAuthType = 'None' #(Equates to basic)

#Establish eDirectory Connection and Enumerate
$Root = New-Object System.DirectoryServices.DirectoryEntry -argumentlist $eDirPath,$eDirUser,$eDirPWD,$eDIrAuthType
$Query = New-Object System.DirectoryServices.DirectorySearcher
$Query.SearchRoot = $Root
#$Query.Filter = "(&(matcorigin=$Origin)(cn=$UserName)(logindisabled=$Disabled)(workforceid=$EmployeeID)(EmployeeStatus=$employeestatus)(EmployeeType=$EmployeeType))"
$Query.Filter = "(&(matcorigin=$Origin)(cn=$UserName)(workforceid=$EmployeeID))"
$SearchResults = $Query.FindAll()

$PropArray = @()

foreach ($result in $SearchResults)
    {
    $Prop = New-Object System.Object
    $Prop | Add-Member -type NoteProperty -name cn -value $result.properties.cn
    $Prop | Add-Member -type NoteProperty -name FullName -value $result.properties.fullname
    $Prop | Add-Member -type NoteProperty -name LastName -value $result.properties.sn
    $Prop | Add-Member -type NoteProperty -name FirstName -value $result.properties.givenname
    $Prop | Add-Member -type NoteProperty -name Initials -value $result.properties.initials
    $Prop | Add-Member -type NoteProperty -name Title -value $result.properties.title
    $Prop | Add-Member -type NoteProperty -name TelephoneNumber -value $result.properties.telephonenumber
    $Prop | Add-Member -type NoteProperty -name ou -value $result.properties.ou
    $Prop | Add-Member -type NoteProperty -name City -value $result.properties.l
    $Prop | Add-Member -type NoteProperty -name AdsPath -value $result.properties.adspath
    $Prop | Add-Member -type NoteProperty -name RoomNumber -value $result.properties.roomnumber
    $Prop | Add-Member -type NoteProperty -name EmplStatus -value $result.properties.employeestatus
    $Prop | Add-Member -type NoteProperty -name Emplid -value $result.properties.workforceid
    $Prop | Add-Member -type NoteProperty -name EmplType -value $result.properties.employeetype
    $Prop | Add-Member -type NoteProperty -name Origin -value $result.properties.matcorigin
    $Prop | Add-Member -type NoteProperty -name DeptNum -value $result.properties.departmentnumber
    $Prop | Add-Member -type NoteProperty -name LocCode -value $result.properties.matclocationcode
    $Prop | Add-Member -type NoteProperty -name LocDesc -value $result.properties.matclocationdesc
    $Prop | Add-Member -type NoteProperty -name JobCode -value $result.properties.jobcode    
    $Prop | Add-Member -type NoteProperty -name MailEnabled -value $result.properties.matcemailenabled 
    $Prop | Add-Member -type NoteProperty -name Benefits -value $result.properties.matcbenefitprogram
    $Prop | Add-Member -type NoteProperty -name Saladmin -value $result.properties.matcsaladminplan
    $Prop | Add-Member -type NoteProperty -name Disabled -value $result.properties.logindisabled
    $Prop | Add-Member -type NoteProperty -name MatcQ -value $result.properties.matcq
    $Prop | Add-Member -type NoteProperty -name MatcA -value $result.properties.matca
    $Prop | Add-Member -type NoteProperty -name PwdReq -value $result.properties.passwordrequired  
    $PropArray += $Prop
    }
    
    $PropArray | ft cn,firstname,lastname,initials,Disabled,origin,emplid,EmplStatus,EmplType,JobCode,MailEnabled,SalAdmin,Benefits,DeptNum -auto
    #$PropArray | fl *
    <#
    ForEach ($Result in $SearchResults) `
        {
        #Convert object to utilize named values like CN, SN, UniqueID
        $eDirObject = [PSCustomObject]$Result.Properties
        write-host "$eDirObject.cn $eDirObject.sn $eDirObject.UniqueID"
        }
    #>
    
    ($PropArray | group emplid | ?{$_.Count -gt 1}) | % {$_.name + "    " + $_.group} 