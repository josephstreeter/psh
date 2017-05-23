Function Create-FGPPs {
New-ADFineGrainedPasswordPolicy `
   -Name "CADS-NETID-FGPP" `
   -DisplayName "CADS-NETID-FGPP" `
   -Description "NetID Password Policy" `
   -ComplexityEnabled $false `
   -LockoutDuration "00.00:00:00" `
   -LockoutObservationWindow "00.00:00:00" `
   -LockoutThreshold "0" `
   -MaxPasswordAge "00.00:00:00" `
   -MinPasswordAge "00.00:00:00" `
   -MinPasswordLength "8" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false `
 
 New-ADFineGrainedPasswordPolicy `
   -Name "CADS-OUADM-FGPP" `
   -DisplayName "CADS-OUADM-FGPP" `
   -Description "OU Admins Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.00:15:00" `
   -LockoutObservationWindow "00.00:15:00" `
   -LockoutThreshold "15" `
   -MaxPasswordAge "180.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "12" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false ` 
 
 New-ADFineGrainedPasswordPolicy `
   -Name "CADS-SENSI-FGPP" `
   -DisplayName "CADS-SENSI-FGPP" `
   -Description "Sensitive Objects Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.00:15:00" `
   -LockoutObservationWindow "00.00:15:00" `
   -LockoutThreshold "5" `
   -MaxPasswordAge "180.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "15" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false ` 
  
 New-ADFineGrainedPasswordPolicy `
   -Name "CADS-SERVI-FGPP" `
   -DisplayName "CADS-SERVI-FGPP" `
   -Description "Service Accounts Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.00:15:00" `
   -LockoutObservationWindow "00.00:15:00" `
   -LockoutThreshold "15" `
   -MaxPasswordAge "365.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "15" `
   -PasswordHistoryCount "12" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false 
   
 New-ADFineGrainedPasswordPolicy `
   -Name "CADS-RESOU-FGPP" `
   -DisplayName "CADS-RESOU-FGPP" `
   -Description "Resource Accounts Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.00:15:00" `
   -LockoutObservationWindow "00.00:15:00" `
   -LockoutThreshold "15" `
   -MaxPasswordAge "365.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "15" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false

New-ADFineGrainedPasswordPolicy `
   -Name "CADS-SHARE-FGPP" `
   -DisplayName "CADS-SHARE-FGPP" `
   -Description "Shared Accounts Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.00:15:00" `
   -LockoutObservationWindow "00.00:15:00" `
   -LockoutThreshold "15" `
   -MaxPasswordAge "365.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "15" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false 

New-ADFineGrainedPasswordPolicy `
   -Name "CADS-AUTO-FGPP" `
   -DisplayName "CADS-AUTO-FGPP" `
   -Description "Auto Login Accounts Password Policy" `
   -ComplexityEnabled $true `
   -LockoutDuration "00.01:00:00" `
   -LockoutObservationWindow "00.00:03:00" `
   -LockoutThreshold "15" `
   -MaxPasswordAge "365.00:00:00" `
   -MinPasswordAge "01.00:00:00" `
   -MinPasswordLength "26" `
   -PasswordHistoryCount "24" `
   -Precedence "10" `
   -ProtectedFromAccidentalDeletion $true `
   -ReversibleEncryptionEnabled $false  
 }
   
 Function Create-Groups {
   New-ADGroup `
   -Name "CADS-DS-NETID-FGPP" `
   -DisplayName "CADS-NETID-FGPP" `
   -Description "NetID Password Policy" `
   -SamAccountName "CADS-DS-NETID-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"
 
 New-ADGroup `
   -Name "CADS-DS-OUADM-FGPP" `
   -DisplayName "CADS-DS-OUADM-FGPP" `
   -Description "OU Admins Password Policy" `
   -SamAccountName "CADS-DS-OUADM-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"
 
 New-ADGroup `
   -Name "CADS-DS-SENSI-FGPP" `
   -DisplayName "CADS-DS-SENSI-FGPP" `
   -Description "Sensitive Objects Password Policy" `
   -SamAccountName "CADS-DS-SENSI-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu" 
  
 New-ADGroup `
   -Name "CADS-DS-SERVI-FGPP" `
   -DisplayName "CADS-DS-SERVI-FGPP" `
   -Description "Service Accounts Password Policy" `
   -SamAccountName "CADS-DS-SERVI-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"
   
 New-ADGroup `
   -Name "CADS-DS-RESOU-FGPP" `
   -DisplayName "CADS-RESOU-FGPP" `
   -Description "Resource Accounts Password Policy" `
   -SamAccountName "CADS-DS-RESOU-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"

New-ADGroup `
   -Name "CADS-DS-SHARE-FGPP" `
   -DisplayName "CADS-DS-SHARE-FGPP" `
   -Description "Shared Accounts Password Policy" `
   -SamAccountName "CADS-DS-SHARE-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"

New-ADGroup `
   -Name "CADS-DS-AUTO-FGPP" `
   -DisplayName "CADS-DS-AUTO-FGPP" `
   -Description "Auto Login Accounts Password Policy" `
   -SamAccountName "CADS-DS-AUTO-FGPP" `
   -GroupCategory Security `
   -GroupScope DomainLocal `
   -Path "OU=Groups,OU=ENT,DC=ad,DC=wisc,DC=edu"
}

Function Connect-FGPPs {
Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-NETID-FGPP" `
   -Subjects "CADS-DS-NETID-FGPP"

Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-OUADM-FGPP" `
   -Subjects "CADS-DS-OUADM-FGPP"

Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-SENSI-FGPP" `
   -Subjects "CADS-DS-SENSI-FGPP"

Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-SERVI-FGPP" `
   -Subjects "CADS-DS-SERVI-FGPP"

Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-RESOU-FGPP" `
   -Subjects "CADS-DS-RESOU-FGPP"
Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-SHARE-FGPP" `
   -Subjects "CADS-DS-SHARE-FGPP"

Add-ADFineGrainedPasswordPolicySubject `
   -Identity "CADS-AUTO-FGPP" `
   -Subjects "CADS-DS-AUTO-FGPP"
}

 Create-FGPPs
 Create-Groups
 Connect-FGPPs