CLS
$xml = [xml] $(Get-Content .\INT056A_Cognos_Worker_20141222121012.xml)

#$x = ($xml.worker_sync.worker.Personal).count
$x = 200
$i = 0

$emplRpt = @()

Do {
$i
If ($xml.worker_sync.worker.Status[$i].Active -eq "true"){
$empl = New-Object System.Object

$empl | add-member -Type NoteProperty -Name "EmplID" -Value $xml.worker_sync.worker.Summary[$i].Employee_ID
#$empl | add-member -Type NoteProperty -Name "givenName" -Value $xml.worker_sync.worker.Personal[$i].Name_Data.First_Name            
#$empl | add-member -Type NoteProperty -Name "sn" -Value $xml.worker_sync.worker.Personal[$i].Name_Data.Last_Name
#$empl | add-member -Type NoteProperty -Name "Initials" -Value ($xml.worker_sync.worker.Personal[$i].Name_Data.Middle_Name).Substring(0,1)
$empl | add-member -Type NoteProperty -Name "Displayname" -Value $xml.worker_sync.worker.Personal[$i].Name_Data.Reporting_Name
#$empl | add-member -Type NoteProperty -Name "Name" -Value $xml.worker_sync.worker.Summary[$i].Name
$empl | add-member -Type NoteProperty -Name "Address" -Value $(If ($xml.worker_sync.worker.Additional_Information[$i].Worker_Room) {$($xml.worker_sync.worker.Additional_Information[$i].Worker_Room + " " + $xml.worker_sync.worker.Personal[$i].Address_Data.Address_Line_Data.'#text')}Else{$xml.worker_sync.worker.Personal[$i].Address_Data.Address_Line_Data.'#text'})
$empl | add-member -Type NoteProperty -Name "City" -Value $xml.worker_sync.worker.Personal[$i].Address_Data.Municipality
$empl | add-member -Type NoteProperty -Name "State" -Value $xml.worker_sync.worker.Personal[$i].Address_Data.Region
$empl | add-member -Type NoteProperty -Name "Zip" -Value $xml.worker_sync.worker.Personal[$i].Address_Data.Postal_Code
#$empl | add-member -Type NoteProperty -Name "DoB" -Value $xml.worker_sync.worker.Personal[$i].Birth_Date  
$empl | add-member -Type NoteProperty -Name "Email" -Value $xml.worker_sync.worker.Personal[$i].Email_Data.Email_Address  
$empl | add-member -Type NoteProperty -Name "telephoneNumber" -Value ($xml.worker_sync.worker.Personal[$i].Phone_Data.Formatted_Phone_Number).Replace("+1 (","").replace(") ",".").replace("-",".")
#$empl | add-member -Type NoteProperty -Name "Eligible" -Value $xml.worker_sync.worker.Eligibility[$i]
#$empl | add-member -Type NoteProperty -Name "Active" -Value $xml.worker_sync.worker.Status[$i].Active
<#$empl | add-member -Type NoteProperty -Name "Ethnicity" -Value $xml.worker_sync.worker.Personal[$i].Ethnicity   
#$empl | add-member -Type NoteProperty -Name "Gender" -Value $xml.worker_sync.worker.Personal[$i].Gender      
#$empl | add-member -Type NoteProperty -Name "Hisp" -Value $xml.worker_sync.worker.Personal[$i].Hispanic_or_Latino   
$empl | add-member -Type NoteProperty -Name "StatusDate" -Value $xml.worker_sync.worker.Status[$i].Active_Status_Date   
$empl | add-member -Type NoteProperty -Name "EmplStatus" -Value $xml.worker_sync.worker.Status[$i].Employee_Status      
$empl | add-member -Type NoteProperty -Name "EmplEmdDate" -Value $xml.worker_sync.worker.Status[$i].End_Employment_Date  
$empl | add-member -Type NoteProperty -Name "EmplHireDate" -Value $xml.worker_sync.worker.Status[$i].Hire_Date            
$empl | add-member -Type NoteProperty -Name "EmplIDReturn" -Value $xml.worker_sync.worker.Status[$i].Not_Returning        
$empl | add-member -Type NoteProperty -Name "EmplOrigHireDate" -Value $xml.worker_sync.worker.Status[$i].Original_Hire_Date   
$empl | add-member -Type NoteProperty -Name "EmplRehire" -Value $xml.worker_sync.worker.Status[$i].Rehire               
$empl | add-member -Type NoteProperty -Name "EmplRetired" -Value $xml.worker_sync.worker.Status[$i].Retired              
$empl | add-member -Type NoteProperty -Name "EmplPosition" -Value $xml.worker_sync.worker.Position[$i].Organization_Data.organization
$empl | add-member -Type NoteProperty -Name "EmplPositionType" -Value $xml.worker_sync.worker.Position[$i].Organization_Data.organization_type
$empl | add-member -Type NoteProperty -Name "EmplJobProfile" -Value $xml.worker_sync.worker.Position[$i].Job_Profile
$empl | add-member -Type NoteProperty -Name "EmplManagementLevel" -Value $xml.worker_sync.worker.Position[$i].Management_Level
$empl | add-member -Type NoteProperty -Name "EmplJobFamily" -Value $xml.worker_sync.worker.Position[$i].Job_Family
$empl | add-member -Type NoteProperty -Name "EmplBusinessSite" -Value $xml.worker_sync.worker.Position[$i].Business_Site
$empl | add-member -Type NoteProperty -Name "EmplBusinessSiteName" -Value $xml.worker_sync.worker.Position[$i].Business_Site_Name
$empl | add-member -Type NoteProperty -Name "EmplBusinessSiteAddr" -Value $xml.worker_sync.worker.Position[$i].Business_Site_Address_Line_Data.'#text'
$empl | add-member -Type NoteProperty -Name "EmplSupervisorID" -Value $xml.worker_sync.worker.Position[$i].Supervisor_ID
$empl | add-member -Type NoteProperty -Name "EmplSupervisor" -Value $xml.worker_sync.worker.Position[$i].Supervisor_Name

$xml.worker_sync.worker.Contract
$empl | add-member -Type NoteProperty -Name "EmplIDCatagory" -Value $xml.worker_sync.worker.Identification_Data[$i].Identification
$empl | add-member -Type NoteProperty -Name "EmplIDNumber" -Value $xml.worker_sync.worker.Identification_Data[$i].ID
$empl | add-member -Type NoteProperty -Name "EmplIDType" -Value $xml.worker_sync.worker.Identification_Data[$i].ID_Type
$empl | add-member -Type NoteProperty -Name "EmplCompGrade" -Value $xml.worker_sync.worker.Additional_Information[$i].Compensation_Grade   
#>
$empl | add-member -Type NoteProperty -Name "EmplCostCenter" -Value $xml.worker_sync.worker.Additional_Information[$i].Cost_Center_Name     
$empl | add-member -Type NoteProperty -Name "EmplType" -Value $xml.worker_sync.worker.Additional_Information[$i].Employee_Type        
#$empl | add-member -Type NoteProperty -Name "EmplDegree" -Value $xml.worker_sync.worker.Additional_Information[$i].Highest_Degree_Earned
#$empl | add-member -Type NoteProperty -Name "EmplJobCode" -Value $xml.worker_sync.worker.Additional_Information[$i].Job_Code         
$empl | add-member -Type NoteProperty -Name "EmplJobFamilyName" -Value $xml.worker_sync.worker.Additional_Information[$i].Job_Family_Name  
#$empl | add-member -Type NoteProperty -Name "EmplLocationID" -Value $xml.worker_sync.worker.Additional_Information[$i].Location_ID      
#$empl | add-member -Type NoteProperty -Name "EmplPayGroup" -Value $xml.worker_sync.worker.Additional_Information[$i].Pay_Group        
#$empl | add-member -Type NoteProperty -Name "EmplIsEmployee" -Value $xml.worker_sync.worker.Additional_Information[$i].WorkerIsEmployee 
#$empl | add-member -Type NoteProperty -Name "EmplHomePhone" -Value $xml.worker_sync.worker.Additional_Information[$i].Worker_home_phone
#$empl | add-member -Type NoteProperty -Name "EmplRoom" -Value $xml.worker_sync.worker.Additional_Information[$i].Worker_Room

$emplrpt += $empl
}

$I++
} While ($i -lt $x)

$emplRpt | ft * #EmplID, givenName, sn, Initials, DisplayName, Address, City, State, Zip, Email, TelephoneNumber, Active -AutoSize