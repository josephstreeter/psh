CLS
"1.1 Set 'Maximum send size - connector level' to '10240' (Scored)"
get-sendconnector | ft identity, MaxMessageSize -AutoSize
"1.2 Set 'Maximum receive size - organization level' to '10240' (Scored)"
Get-TransportConfig | ft identity, MaxReceiveSize -AutoSize
"1.3 Set 'Enable Sender ID agent' to 'True' (Scored)"
Get-SenderIDConfig | ft InternalMailEnabled -AutoSize
"1.4 Set 'External send connector authentication: DNS Routing' to 'True' (Not Scored)"
Get-SendConnector | ft identity, DNSRoutingEnabled
"1.5 Set 'Configure Sender Filtering' to 'Reject' (Scored)"
Get-SenderFilterConfig | ft identity, Enabled
"1.6 Set 'Enable Sender reputation' to 'True' (Scored)"
Get-SenderReputationConfig | ft SenderBlockingEnabled, OpenProxyDetectionEnabled
"1.7 Set 'Maximum number of recipients - organization level' to '5000' (Scored)"
Get-TransportServer | ft name, PickupDirectoryMaxRecipientsPerMessage -AutoSize
"1.8 Set 'External send connector authentication: Ignore Start TLS' to 'False' (Scored)"
Get-SendConnector | ft Identity, IgnoreSTARTTLS
"1.9 Set 'Configure login authentication for POP3' to 'SecureLogin' (Scored)"
Get-PopSettings | ft Identity, LoginType -AutoSize
"1.10 Set receive connector 'Configure Protocol logging' to 'Verbose' (Scored)"
Get-ReceiveConnector | ft Identity, ProtocolLoggingLevel -AutoSize
"1.11 Set send connector 'Configure Protocol logging' to 'Verbose' (Scored)"
Get-SendConnector | ft Identity, ProtocolLoggingLevel -AutoSize
"1.12 Set 'External send connector authentication: Domain Security' to 'True' (Scored)"
get-sendconnector | ft Identity, DomainSecureEnabled
"1.13 Set 'Message tracking logging - Transport' to 'True' (Scored)"
Get-TransportServer| ft Identity, MessageTrackingLogEnabled
"1.14 Set 'Message tracking logging - Mailbox' to 'True' (Scored)"
Get-MailboxServer| ft Identity, MessageTrackingLogEnabled
"1.15 Set 'Configure login authentication for IMAP4' to 'SecureLogin' (Scored)"
Get-ImapSettings | ft Identity, LoginType -AutoSize
"1.16 Set 'Turn on Connectivity logging' to 'True' (Scored)"
Get-TransportServer | ft Identity, ConnectivityLogEnabled
"1.17 Set 'Maximum send size - organization level' to '10240' (Scored)"
Get-TransportConfig | ft Identity, MaxSendSize
"1.18 Set 'Maximum receive size - connector level' to '10240' (Scored)"
get-receiveconnector | ft identity, MaxMessageSize -AutoSize
"2.1 Set 'Mailbox quotas: Issue warning at' to '1991680' (Not Scored)"
Get-MailboxDatabase | ft Identity, IssueWarningQuota
"2.2 Set 'Mailbox quotas: Prohibit send and receive at' to '2411520' (Not Scored)"
Get-MailboxDatabase | ft Identity, ProhibitSendReceiveQuota
"2.3 Set 'Mailbox quotas: Prohibit send at' to '2097152' (Not Scored)"
Get-MailboxDatabase | ft Identity, ProhibitSendQuota
"2.4 Set 'Keep deleted mailboxes for the specified number of days' to '30' (Scored)"
Get-Mailboxdatabase | ft Identity, MailboxRetention
"2.5 Set 'Do not permanently delete items until the database has been backed up' to 'True' (Scored)"
Get-MailboxDatabase | ft Identity, RetainDeletedItemsUntilBackup
"2.6 Set 'Allow simple passwords' to 'False' (Scored)"
Get-ActiveSyncMailboxPolicy | ft AllowSimpleDevicePassword
"2.7 Set 'Enforce Password History' to '4' (Scored)"
Get-ActiveSyncMailboxPolicy | ft DevicePasswordHistory
"2.8 Set 'Password Expiration' to '90' (Scored)"
Get-ActiveSyncMailboxPolicy | ft DevicePasswordExpiration
"2.9 Set 'Minimum password length' to '4' (Scored)"
Get-ActiveSyncMailboxPolicy | ft MinDevicePasswordLength
"2.10 Set 'Configure startup mode' to 'TLS' (Scored)"
Get-UMServer | ft Identity, UMStartUpMode
"2.11 Set 'Refresh interval' to '1' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, DevicePolicyRefreshInterval
"2.12 Set 'Configure dial plan security' to 'Secured' (Scored)"
Get-UMDialPlan | ft identity, VoIPSecurity
"2.13 Set 'Allow access to voicemail without requiring a PIN' to 'False' (Scored)"
Get-UMMailboxPolicy | ft identity, AllowPinlessVoiceMailAccess
"2.14 Set 'Retain deleted items for the specified number of days' to '14' (Scored)"
Get-MailboxDatabase | ft identity, DeletedItemRetention
"2.15 Set 'Allow unmanaged devices' to 'False' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, AllowNonProvisionableDevices
"2.16 Set 'Require encryption on device' to 'True' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, RequireDeviceEncryption
"2.17 Set 'Time without user input before password must be re-entered' to '15' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, MaxInactivityTimeDeviceLock
"2.18 Set 'Require alphanumeric password' to 'True' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, AlphanumericDevicePasswordRequired
"2.19 Set 'Require client MAPI encryption' to 'True' (Scored)"
Get-CASMailbox | ft MAPIEnabled
"2.20 Set 'Number of attempts allowed' to '10' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, MaxDevicePasswordFailedAttempts
"2.21 Set 'Require password' to 'True' (Scored)"
Get-ActiveSyncMailboxPolicy | ft Identity, DevicePasswordEnabled
"3.1 Set cmdlets 'Turn on Administrator Audit Logging' to 'True' (Scored)"
Get-AdminAuditLogConfig | ft AdminAuditLogCmdlets
"3.2 Set 'Require Client Certificates' to 'Required' (Not Scored)"
"N/A"
"3.3 Set 'Turn on script execution' to 'RemoteSigned' (Scored)"
Get-ExecutionPolicy | ft RemoteSigned
"3.4 Set 'Turn on Administrator Audit Logging' to 'True' (Scored)"
Get-AdminAuditLogConfig | ft AdminAuditLogEnabled
"3.5 Set 'Enable automatic replies to remote domains' to 'False' (Scored)"
Get-RemoteDomain | ft Identity, AutoReplyEnabled
"3.6 Set 'Allow basic authentication' to 'False' (Scored)"
Get-OwaVirtualDirectory | ft Identity, BasicAuthentication
"3.7 Set 'Enable non-delivery reports to remote domains' to 'False' (Scored)"
Get-RemoteDomain | ft Identity, NDREnabled
"3.8 Set 'Enable OOF messages to remote domains' to 'None' (Scored)"
Get-RemoteDomain | ft Identity, AllowedOOFType
"3.9 Set 'Enable automatic forwards to remote domains' to 'False' (Scored)"
Get-RemoteDomain | ft Identity, AutoForwardEnabled
"3.10 Set 'Enable S/MIME for OWA 2010' to 'True' (Scored)"
Get-OWAVirtualDirectory | ft Identity, SMimeEnabled
"3.11 Set mailbox 'Turn on Administrator Audit Logging' to 'True' (Scored)"
Get-AdminAuditLogConfig | ft AdminAuditLogEnabled
