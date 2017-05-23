$DNSServer=@()
$CacheRpt=@()
$DiagRpt=@()
$DsRpt=@()
$EDNSRpt=@()
$FwdRpt=@()
$EdnsRpt=@()
$FwdRpt=@()
$GlobalRpt=@()
$BlockListRPT=@()
$RecurseRpt=@()
$RootHintRpt=@()
$ScavengingRpt=@()
$SettingRpt=@()
$ZoneRpt=@()
$ZoneAgingRpt=@()
$ZoneScopeRpt=@()

Foreach ($DC in $(Get-ADDomainController -Filter 'name -ne "MCRODC"' | sort name))
    {
    $DNS = Get-DnsServer -ComputerName $DC.Hostname -ea SilentlyContinue -WarningAction SilentlyContinue

    $Cache = New-Object -TypeName System.Object
    $Cache | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Cache | Add-Member -MemberType NoteProperty -Name MaxTTL -Value $DNS.ServerCache.MaxTtl
    $Cache | Add-Member -MemberType NoteProperty -Name MaxNegativeTtl -Value $DNS.ServerCache.MaxNegativeTtl
    $Cache | Add-Member -MemberType NoteProperty -Name EnablePollutionProtection -Value $DNS.ServerCache.EnablePollutionProtection
    $Cache | Add-Member -MemberType NoteProperty -Name LockingPercent -Value $DNS.ServerCache.LockingPercent
    $CacheRpt += $Cache

    $Diag = New-Object -TypeName System.Object
    $Diag | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Diag | Add-Member -MemberType NoteProperty -Name SaveLogsToPersistentStorage  -Value $DNS.ServerDiagnostics.SaveLogsToPersistentStorage 
    $Diag | Add-Member -MemberType NoteProperty -Name Queries -Value $DNS.ServerDiagnostics.Queries 
    $Diag | Add-Member -MemberType NoteProperty -Name Answers -Value $DNS.ServerDiagnostics.Answers
    $Diag | Add-Member -MemberType NoteProperty -Name EnableLoggingToFile -Value $DNS.ServerDiagnostics.EnableLoggingToFile 
    $Diag | Add-Member -MemberType NoteProperty -Name LogFilePath -Value $DNS.ServerDiagnostics.LogFilePath
    $DiagRpt += $Diag

    $Ds = New-Object -TypeName System.Object
    $Ds | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Ds | Add-Member -MemberType NoteProperty -Name PollingInterval  -Value $DNS.ServerDsSetting.PollingInterval
    $Ds | Add-Member -MemberType NoteProperty -Name DirectoryPartitionAutoEnlistInterval -Value $DNS.ServerDsSetting.DirectoryPartitionAutoEnlistInterval
    $Ds | Add-Member -MemberType NoteProperty -Name LazyUpdateInterval -Value $DNS.ServerDsSetting.LazyUpdateInterval
    $Ds | Add-Member -MemberType NoteProperty -Name MinimumBackgroundLoadThreads -Value $DNS.ServerDsSetting.MinimumBackgroundLoadThreads
    $DsRpt += $Ds 

    $EDNS = New-Object -TypeName System.Object
    $EDNS | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $EDNS | Add-Member -MemberType NoteProperty -Name CacheTimeout -Value $DNS.ServerEdns.CacheTimeout
    $EDNS | Add-Member -MemberType NoteProperty -Name EnableProbes -Value $DNS.ServerEdns.EnableProbes
    $EDNS | Add-Member -MemberType NoteProperty -Name EnableReception -Value $DNS.ServerEdns.EnableReception
    $EDNSRpt += $EDNS      

    $Fwd = New-Object -TypeName System.Object
    $Fwd | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Fwd | Add-Member -MemberType NoteProperty -Name UseRootHint -Value $DNS.ServerForwarder.UseRootHint
    $Fwd | Add-Member -MemberType NoteProperty -Name Timeout -Value $DNS.ServerForwarder.Timeout
    $Fwd | Add-Member -MemberType NoteProperty -Name IPAddress -Value $DNS.ServerForwarder.IPAddress
    $Fwd | Add-Member -MemberType NoteProperty -Name EnabledReordering -Value $DNS.ServerForwarder.EnabledReordering
    $Fwd | Add-Member -MemberType NoteProperty -Name ReorderedIPAddress -Value $DNS.ServerForwarder.ReorderedIPAddress
    $FwdRpt += $Fwd

    $Global = New-Object -TypeName System.Object
    $Global | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Global | Add-Member -MemberType NoteProperty -Name Enable -Value $DNS.ServerGlobalNameZone.Enable
    $Global | Add-Member -MemberType NoteProperty -Name GlobalOverLocal -Value $DNS.ServerGlobalNameZone.GlobalOverLocal
    $Global | Add-Member -MemberType NoteProperty -Name PreferAAAA -Value $DNS.ServerGlobalNameZone.PreferAAAA
    $Global | Add-Member -MemberType NoteProperty -Name AlwaysQueryServer-Value $DNS.ServerGlobalNameZone.AlwaysQueryServer
    $Global | Add-Member -MemberType NoteProperty -Name BlockUpdates -Value $DNS.ServerGlobalNameZone.BlockUpdates
    $GlobalRpt += $Global

    $BlockList = New-Object -TypeName System.Object
    $BlockList | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $BlockList | Add-Member -MemberType NoteProperty -Name UseRootHint -Value $DNS.ServerGlobalQueryBlockList.Enable
    $BlockList | Add-Member -MemberType NoteProperty -Name Timeout -Value $DNS.ServerGlobalQueryBlockList.List
    $BlockListRpt += $BlockList

    $Recurse = New-Object -TypeName System.Object
    $Recurse | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Recurse | Add-Member -MemberType NoteProperty -Name Enable -Value $DNS.ServerRecursion.Enable
    $Recurse | Add-Member -MemberType NoteProperty -Name AdditionalTimeout -Value $DNS.ServerRecursion.AdditionalTimeout
    $Recurse | Add-Member -MemberType NoteProperty -Name RetryInterval -Value $DNS.ServerRecursion.RetryInterval
    $Recurse | Add-Member -MemberType NoteProperty -Name Timeout -Value $DNS.ServerRecursion.Timeout
    $Recurse | Add-Member -MemberType NoteProperty -Name SecureResponse -Value $DNS.ServerRecursion.SecureResponse
    $RecurseRpt += $Recurse

    $RootHint = New-Object -TypeName System.Object
    $RootHint | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $RootHint | Add-Member -MemberType NoteProperty -Name RootHints -Value $DNS.ServerRootHint.nameserver.recorddata.nameserver
    $RootHintRpt += $RootHint

    $Scavenging = New-Object -TypeName System.Object
    $Scavenging | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Scavenging | Add-Member -MemberType NoteProperty -Name NoRefreshInterval -Value $DNS.ServerScavenging.NoRefreshInterval
    $Scavenging | Add-Member -MemberType NoteProperty -Name RefreshInterval -Value $DNS.ServerScavenging.RefreshInterval
    $Scavenging | Add-Member -MemberType NoteProperty -Name ScavengingInterval -Value $DNS.ServerScavenging.ScavengingInterval
    $Scavenging | Add-Member -MemberType NoteProperty -Name ScavengingState -Value $DNS.ServerScavenging.ScavengingState
    $Scavenging | Add-Member -MemberType NoteProperty -Name LastScavengeTime -Value $DNS.ServerScavenging.LastScavengeTime
    $ScavengingRpt += $Scavenging

    $Setting = New-Object -TypeName System.Object
    $Setting | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
    $Setting | Add-Member -MemberType NoteProperty -Name MajorVersion -Value $DNS.ServerSetting.MajorVersion
    $Setting | Add-Member -MemberType NoteProperty -Name MinorVersion -Value $DNS.ServerSetting.MinorVersion
    $Setting | Add-Member -MemberType NoteProperty -Name IsReadOnlyDC -Value $DNS.ServerSetting.IsReadOnlyDC
    $Setting | Add-Member -MemberType NoteProperty -Name EnableDnsSec -Value $DNS.ServerSetting.EnableDnsSec
    $Setting | Add-Member -MemberType NoteProperty -Name EnableIPv6 -Value $DNS.ServerSetting.EnableIPv6
    $SettingRpt += $Setting

    foreach ($Zone in $DNS.ServerZone)
        {
        $ZoneInfo = New-Object -TypeName System.Object
        $ZoneINfo | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name ZoneName -Value $Zone.ZoneName
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name ZoneType -Value $Zone.ZoneType
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name IsAutoCreated -Value $Zone.IsAutoCreated
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name IsDsIntegrated -Value $Zone.IsDsIntegrated
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name IsReverseLookupZone -Value $Zone.IsReverseLookupZone
        $ZoneInfo | Add-Member -MemberType NoteProperty -Name IsSigned -Value $Zone.IsSigned
        $ZoneRpt += $ZoneInfo
        }

    foreach ($ZoneAge in $DNS.ServerZoneAging)
        {
        if ($zoneAge.ZoneName)
            {
            $ZoneAging = New-Object -TypeName System.Object
            $ZoneAging | Add-Member -MemberType NoteProperty -Name Name -Value $DC.HostName
            $ZoneAging | Add-Member -MemberType NoteProperty -Name ZoneName -Value $ZoneAge.ZoneName
            $ZoneAging | Add-Member -MemberType NoteProperty -Name AgingEnabled-Value $ZoneAge.AgingEnabled
            $ZoneAging | Add-Member -MemberType NoteProperty -Name AvailForScavengeTime -Value $ZoneAge.AvailForScavengeTime
            $ZoneAging | Add-Member -MemberType NoteProperty -Name RefreshInterval -Value $ZoneAge.RefreshInterval.Days
            $ZoneAging | Add-Member -MemberType NoteProperty -Name NoRefreshInterval -Value $ZoneAge.NoRefreshInterval.Days
            $ZoneAging | Add-Member -MemberType NoteProperty -Name ScavengeServers -Value $ZoneAge.ScavengeServers
            $ZoneAgingRpt += $ZoneAging
            }
        }
    }

"`nDNS Cache Settings"
"________________________"
$CacheRpt | ft -AutoSize
"`nDNS Diagnostic Settings"
"________________________"
$DiagRpt | ft -AutoSize
"`nDNS DS Settings"
"________________________"
$DsRpt | ft -AutoSize
"`nDNS eDNS Settings"
"________________________"
$EDNSRpt | ft -AutoSize
"`nDNS Forwarder Settings"
"________________________"
$FwdRpt | ft -AutoSize
"`nDNS Global Name Settings"
"________________________"
$GlobalRpt | ft -AutoSize
"`nDNS Block List Settings"
"________________________"
$BlockListRpt | ft -AutoSize
"`nDNS Recursive Settings"
"________________________"
$RecurseRpt | ft -AutoSize
"`nDNS Root Hints"
"________________________"
$RootHintRpt | ft -AutoSize
"`nDNS Server Scavenging Settings"
"________________________"
$ScavengingRpt | ft -AutoSize
"`nDNS Cache Settings"
"________________________"
$SettingRpt | ft -AutoSize
"`nDNS Zones"
"________________________"
$ZoneRpt | ? {$_.zonename -eq "MATC.Madison.Login" }| sort IsReverseLookupZone,zonename | ft -AutoSize
"`nDNS Zone Aging"
"________________________"
$ZoneAgingRpt | ? {$_.zonename -eq "MATC.Madison.Login" } | sort zonename,name | ft -AutoSize