# http://konab.com/scheduling-mim-advanced-options/
############
# PARAMETERS
############
 
Import-Module sqlps

$RunType = "Full"

If ($RunType -eq "Delta")
    {
    $ImportAsJob = 
        @(
        @{MAName="SQLMA-SD";ProfileToRun="DI";};
        @{MAName="MIMMA";ProfileToRun="DI";};
        @{MAName="ADMA-Main";ProfileToRun="DI";};
        @{MAName="ADMA-DMZ";ProfileToRun="DI";};
        );
 
    $SyncProfilesOrder = 
        @(
        @{MAName="SQLMA-SD";profilesToRun=@("DS");};
        @{MAName="MIMMA";profilesToRun=@("EX";"Sleep:15";"DI";"DS");};
        @{MAName="ADMA-Main";profilesToRun=@("DS");};
        @{MAName="ADMA-DMZ";profilesToRun=@("DS");};
        );
 
    $ExportAsJob = 
        @(
        @{MAName="ADMA-Main";ProfileToRun="EX";};
        @{MAName="ADMA-DMZ";ProfileToRun="EX";};
        @{MAName="SQLMA-SD";ProfileToRun="EX";};
        @{MAName="MIMMA";ProfileToRun="EX";};
        );
    #Log "Info" "Running Delta Syncs"
    }
ElseIf ($RunType -eq "Full")
    {
        $ImportAsJob = 
        @(
        @{MAName="SQLMA-SD";ProfileToRun="FI";};
        @{MAName="MIMMA";ProfileToRun="FI";};
        @{MAName="ADMA-Main";ProfileToRun="FI";};
        @{MAName="ADMA-DMZ";ProfileToRun="FI";};
        );
 
    $SyncProfilesOrder = 
        @(
        @{MAName="SQLMA-SD";profilesToRun=@("FS");};
        @{MAName="MIMMA";profilesToRun=@("EX";"Sleep:15";"DI";"FS");};
        @{MAName="ADMA-Main";profilesToRun=@("FS");};
        @{MAName="ADMA-DMZ";profilesToRun=@("FS");};
        );
 
    $ExportAsJob = 
        @(
        @{MAName="ADMA-Main";ProfileToRun="EX";};
        @{MAName="ADMA-DMZ";ProfileToRun="EX";};
        @{MAName="SQLMA-SD";ProfileToRun="EX";};
        @{MAName="MIMMA";ProfileToRun="EX";};
        );
    #Log "Info" "Running Full Syncs"
    }
Else
    {
    "No run type selected"
    }

$Query = @"

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'Identities_Delta')
BEGIN
  DROP TABLE Identities_Delta;
END

USE [StagingDirectory]
GO

/****** Object:  Table [dbo].[Identities]    Script Date: 4/7/2016 8:11:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Identities_Delta](
	[identityID] [bigint] IDENTITY(1,1) NOT NULL,
	[accountName] [varchar](50) NULL,
	[email] [varchar](100) NULL,
	[changeType] [varchar](50) NULL,
	[city] [varchar](50) NULL,
	[company] [varchar](255) NULL,
	[costCenter] [varchar](255) NULL,
	[department] [nvarchar](100) NULL,
	[displayName] [varchar](50) NULL,
	[employeeEndDate] [varchar](50) NULL,
	[employeeID] [varchar](50) NULL,
	[employeeStartDate] [varchar](50) NULL,
	[employeeStatus] [varchar](50) NULL,
	[employeeType] [varchar](50) NULL,
	[firstName] [varchar](100) NULL,
	[isContingent] [varchar](50) NULL,
	[isFaculty] [varchar](50) NULL,
	[isRetired] [varchar](50) NULL,
	[jobCode] [nvarchar](255) NULL,
	[jobTitle] [nvarchar](255) NULL,
	[initials] [varchar](50) NULL,
	[ipPhone] [varchar](50) NULL,
	[lastName] [varchar](50) NULL,
	[manager] [nvarchar](255) NULL,
	[managerID] [nvarchar](255) NULL,
	[mobilePhone] [varchar](255) NULL,
	[officeLocation] [varchar](255) NULL,
	[officeLocationCode] [varchar](50) NULL,
	[officePhone] [varchar](50) NULL,
	[personalEmail] [varchar](255) NULL,
	[positionID] [varchar](255) NULL,
	[positionTime] [nvarchar](255) NULL,
	[postalCode] [varchar](50) NULL,
	[roomNumber] [varchar](255) NULL,
	[st] [varchar](50) NULL,
	[streetAddress] [varchar](255) NULL,
	[contractEndDate] [varchar](50) NULL,
	[employeeNumber] [varchar](100) NULL,
	[isActivated] [varchar](50) NULL,
	[isFERPA] [varchar](50) NULL,
	[preferredName] [varchar](255) NULL,
	[dateOfBirth] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET IDENTITY_INSERT Identities_Delta OFF
GO

INSERT INTO	Identities_Delta 
		(
		accountName,
		email,
		changeType,
		city,
		company,
		costCenter,
		department,
		displayName,
		employeeEndDate,
		employeeID,
		employeeStartDate,
		employeeStatus,
		employeeType,
		firstName,
		isContingent,
		isFaculty,
		isRetired,
		jobCode,
		jobTitle,
		initials,
		ipPhone,
		lastName,
		manager,
		managerID,
		mobilePhone,
		officeLocation,
		officeLocationCode,
		officePhone,
		personalEmail,
		positionID,
		positionTime,
		postalCode,
		roomNumber,
		st,
		streetAddress,
		contractEndDate,
		employeeNumber,
		isActivated,
		isFERPA,
		preferredName,
		dateOfBirth
		)
SELECT	s.accountName,
		s.email,
		'Add' AS ChangeType,
		s.city,
		s.company,
		s.costCenter,
		s.department,
		s.displayName,
		s.employeeEndDate,
		s.employeeID,
		s.employeeStartDate,
		s.employeeStatus,
		s.employeeType,
		s.firstName,
		s.isContingent,
		s.isFaculty,
		s.isRetired,
		s.jobCode,
		s.jobTitle,
		s.initials,
		s.ipPhone,
		s.lastName,
		s.manager,
		s.managerID,
		s.mobilePhone,
		s.officeLocation,
		s.officeLocationCode,
		s.officePhone,
		s.personalEmail,
		s.positionID,
		s.positionTime,
		s.postalCode,
		s.roomNumber,
		s.st,
		s.streetAddress,
		s.contractEndDate,
		s.employeeNumber,
		s.isActivated,
		s.isFERPA,
		s.preferredName,
		s.dateOfBirth
FROM	dbo.Identities_Archive AS a RIGHT OUTER JOIN
        dbo.Identities AS s ON a.employeeNumber = s.employeeNumber
WHERE   (a.employeeNumber IS NULL)

INSERT INTO	Identities_Delta 
		(
		accountName,
		email,
		changeType,
		city,
		company,
		costCenter,
		department,
		displayName,
		employeeEndDate,
		employeeID,
		employeeStartDate,
		employeeStatus,
		employeeType,
		firstName,
		isContingent,
		isFaculty,
		isRetired,
		jobCode,
		jobTitle,
		initials,
		ipPhone,
		lastName,
		manager,
		managerID,
		mobilePhone,
		officeLocation,
		officeLocationCode,
		officePhone,
		personalEmail,
		positionID,
		positionTime,
		postalCode,
		roomNumber,
		st,
		streetAddress,
		contractEndDate,
		employeeNumber,
		isActivated,
		isFERPA,
		preferredName,
		dateOfBirth
		)
SELECT	s.accountName,
		s.email,
		'Modify' AS ChangeType,
		s.city,
		s.company,
		s.costCenter,
		s.department,
		s.displayName,
		s.employeeEndDate,
		s.employeeID,
		s.employeeStartDate,
		s.employeeStatus,
		s.employeeType,
		s.firstName,
		s.isContingent,
		s.isFaculty,
		s.isRetired,
		s.jobCode,
		s.jobTitle,
		s.initials,
		s.ipPhone,
		s.lastName,
		s.manager,
		s.managerID,
		s.mobilePhone,
		s.officeLocation,
		s.officeLocationCode,
		s.officePhone,
		s.personalEmail,
		s.positionID,
		s.positionTime,
		s.postalCode,
		s.roomNumber,
		s.st,
		s.streetAddress,
		s.contractEndDate,
		s.employeeNumber,
		s.isActivated,
		s.isFERPA,
		s.preferredName,
		s.dateOfBirth
FROM	dbo.Identities_Archive AS a INNER JOIN
        dbo.Identities AS s ON a.employeeNumber = s.employeeNumber
WHERE   a.firstName <> s.firstName OR
		a.LastName <> s.lastname OR
		a.initials <> s.initials OR
		a.employeeStatus <> s.employeeStatus OR
		a.employeeType <> s.employeeType OR
		a.employeeEndDate <> s.employeeEndDate OR
		a.employeeStartDate <> s.employeeStartDate


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'Identities_Archive')
BEGIN
  DROP TABLE Identities_Archive;
END

SELECT * INTO Identities_Archive
FROM Identities

--TRUNCATE TABLE Identities_Delta
"@

$Global:server = "http://tsexmb3.matc.ts.test/powershell"
$Global:LDAPFilterActive = "(&(userAccountControl=66048)(&(employeeNumber=*)(employeeType=*)(employeeID=*)))"
$Global:LDAPFilterInactive = "(&(employeeNumber=*)(employeeType=*)(employeeID=*))"
$Global:date = get-date -uformat "%Y-%m-%d"
$Global:FilePath = "C:\Scripts"
$Global:Logfile = $FilePath + "\"+$date+"-Exchange-Provisioning.txt"
$ActiveEmployeeOUs = @(
    "OU=Staff,OU=FacStaff,DC=MATC,DC=ts,DC=test",
    "OU=Faculty,OU=FacStaff,DC=MATC,DC=ts,DC=test",
    "OU=TechServices,OU=FacStaff,DC=MATC,DC=ts,DC=test",
    "OU=nonEmployee,DC=MATC,DC=ts,DC=test",
    "OU=EmailOnly,DC=MATC,DC=ts,DC=test"
    )
$InactiveEmployeeOUs = @(
    "OU=Staff,OU=DisabledAccounts,DC=MATC,DC=ts,DC=test"
    )
     
############
# DATA
############
$MAs = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername ".")
 
############
# FUNCTIONs
############
function RunFIMAsJob
    {
    param([string]$MAName, [string]$Profile)
    Start-Job -Name $MAName -ArgumentList $MAName,$Profile -ScriptBlock {
        param($MAName,$Profile)
        $MA = (get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername "." -Filter "Name='$MAName'")
        $return = $MA.Execute($Profile)
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + "Starting : " + $MAName + " : " + $Profile + " : " + $return.ReturnValue
        }
    }

Function Create-DeltaTable
    {
    $Instance = "idmdbprd01\mimstage"
    $DataBase = "stagingdirectory"


    Invoke-Sqlcmd `
        -ServerInstance $Instance `
        -Database $DataBase `
        -query $Query
    } 

Function Log($EntryType,$entry)
        {
        $datetime = get-date -uformat "%Y-%m-%d-%H:%M:%S"
        if (-not(get-item $Logfile -ea 0))
            {
            $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile
            }
            Else
            {
            $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile -Append
            }
        }

Function Connect-Exchange($Server)
        {
        if ($global:session)
            {
            Remove-PSSession $global:session
            }
    
        $skipCertificate = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
        $global:session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $server -Authentication Kerberos -SessionOption $skipCertificate 
        
        Log "Info" "Connecting to Exchange"
        
        Try {Import-PSSession $global:session}
        Catch {Log "Error" "Cannot connect to Exchange Server" ; Break}
        }

Function Create-Mailboxes
    {
    Log "Info" "Begin creating mailboxes"
    Foreach ($ActiveEmployeeOU in $ActiveEmployeeOUs)
        {
        $i=0
        Log "Info" "Working on $($ActiveEmployeeOU)"
        $Users = Get-ADUser -LDAPFilter $LDAPFilterActive -searchbase $ActiveEmployeeOU

        Foreach ($User in $Users)
            {
            if (Get-Mailbox $User.SamAccountName -ea 0)
                {
                #Log "Success" "Nothing to do for $($User.SamAccountName)"
                $i++
                }
                Else
                {
                If (Enable-Mailbox $user.SamAccountName -ea 0)
                    {
                    Log "Success" "Created mailbox for $($User.SamAccountName)"
                    }
                    Else
                    {
                    Log "Error" "Failed to create mailbox for $($User.SamAccountName) - $($Error[0].Exception)"
                    }
                }
            }
        Log "Info" "Done working on $($ActiveEmployeeOU). $i Mailboxes"
        }
    }

Function Delete-Mailboxes
    {
    Log "Info" "Begin Removing mailboxes"
    Foreach ($InactiveEmployeeOU in $InactiveEmployeeOUs)
        {
        $i=0
        Log "Info" "Working on $($InactiveEmployeeOU)"
        $Users = Get-ADUser -LDAPFilter $LDAPFilterInactive -searchbase $InactiveEmployeeOU

        Foreach ($User in $Users)
            {
            if (Get-Mailbox $User.SamAccountName -ea 0)
                {
                if (Disable-Mailbox $user.SamAccountName -Confirm:$False -ea 0)
                    {
                    Log "Success" "Disabled mailbox for $($User.SamAccountName)"
                    $i++
                    }
                    Else
                    {
                    Log "Error" "Failed to disable mailbox for $($User.SamAccountName) - $($Error[0].Exception)"
                    }
                }
                Else
                {
                #Log "Success" "Nothing to do for $($User.SamAccountName)"
                }
            }
        Log "Info" "Done working on $($InactiveEmployeeOU). $i Mailboxes"
        }
    }


############
# PROGRAM
############
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": Starting Schedule"

Log "Info" "Starting Synchronization Schedule"

(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Creating SQL Delta Table"
Log "Info" "Creating SQL Delta Table"

Create-DeltaTable

#ImportAsJob
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Starting Import Jobs"
Log "Info" "Starting Import Jobs"

foreach($MAToRun in $ImportAsJob)
    {
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": Starting : " + $MAToRun.MAName + " : " + $MAToRun.ProfileToRun
        Log "Info" "Starting : $($MAToRun.MAName) : $($MAToRun.ProfileToRun)"
        
        $void = RunFIMAsJob $MAToRun.MAName $MAToRun.ProfileToRun
    }
Get-Job | Wait-Job | Receive-Job -Keep
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Finished Import Jobs"
Log "Info" "Finishing Import Jobs"
 
#Removing Jobs to release resources
Get-Job | Remove-Job
 
#Sync (not as job)
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Starting Sync Jobs"
Log "Info" "Starting Sync Jobs"
foreach($MAToRun in $SyncProfilesOrder)
    {
    foreach($profileName in $MAToRun.profilesToRun)
        {
        if($profileName.StartsWith("Sleep"))
            {Start-Sleep -Seconds $profileName.Split(":")[1]}
        elseif($profileName.StartsWith("Script"))
            {& ($scriptpath +"\"+ ($profileName.Split(":")[1]))}
        else
            {
            $return = ($MAs | ?{$_.Name -eq $MAToRun.MAName}).Execute($profileName)
            (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": " + $MAToRun.MAName + " : " + $profileName + " : " + $return.ReturnValue
            Log "Info" "Starting : $($MAToRun.MAName) : $($profileName) : $($return.ReturnValue)"
            }
        }
    }
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Finished Sync Jobs"
Log "Info" "Finishing Sync Jobs"
 
#ExportAsJob
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Starting ExportJobs"
foreach($MAToRun in $ExportAsJob)
    {
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": Starting : " + $MAToRun.MAName + " : " + $MAToRun.ProfileToRun
        Log "Info" ": Starting : $($MAToRun.MAName) : $($MAToRun.ProfileToRun)"
        $void = RunFIMAsJob $MAToRun.MAName $MAToRun.ProfileToRun
    }
Get-Job | Wait-Job | Receive-Job -Keep
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') +": Finished ExportJobs"
Log "Info" "Finished ExportJobs"

#Removing Jobs to release resources
Get-Job | Remove-Job
 
(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": Finished Schedule"
Log "Info" "Finished Schedule"

#Exchange Provisioning

Log "Info" "############ Start ################"
#Connect-Exchange $Server
#Create-Mailboxes
#Delete-Mailboxes
Log "Info" "############ Finished ################"