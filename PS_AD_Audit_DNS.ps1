
$DCs = (Get-ADDomainController -Filter *)
$ScavengeReport = @()
$RecurReport = @()
$ZoneReport = @()
  Foreach ($DC in $DCs) {
    ""
    $DNSSettings = Get-DnsServer -computer $DC -WarningAction SilentlyContinue

    $ScavengeProp = New-Object System.Object
    $ScavengeProp | Add-Member -type NoteProperty -name Server -value $DC
    $ScavengeProp | Add-Member -type NoteProperty -name LastScavengeTime -value $DNSSettings.ServerScavenging.LastScavengeTime
    $ScavengeProp | Add-Member -type NoteProperty -name NoRefreshInterval -value $DNSSettings.ServerScavenging.NoRefreshInterval 
    $ScavengeProp | Add-Member -type NoteProperty -name ScavengingInterval -value $DNSSettings.ServerScavenging.ScavengingInterval
    $ScavengeProp | Add-Member -type NoteProperty -name ScavengingState -value $DNSSettings.ServerScavenging.ScavengingState 
    $ScavengeReport += $ScavengeProp

    $RecurProp = New-Object System.Object
    $RecurProp | Add-Member -type NoteProperty -name Server -value $DC
    $RecurProp | Add-Member -type NoteProperty -name RecursionEnable -value $DNSSettings.ServerRecursion.Enable
    $RecurProp | Add-Member -type NoteProperty -name AdditionalTimeout -value $DNSSettings.ServerRecursion.AdditionalTimeout
    $RecurProp | Add-Member -type NoteProperty -name RetryInterval -value $DNSSettings.ServerRecursion.RetryInterval
    $RecurProp | Add-Member -type NoteProperty -name Timeout -value $DNSSettings.ServerRecursion.Timeout
    $RecurProp | Add-Member -type NoteProperty -name SecureResponse  -value $DNSSettings.ServerRecursion.SecureResponse 
    $RecurReport += $RecurProp
}


"######### Zone Settings #########"
Foreach ($DC in $DCs) {

    Foreach ($Zone in ($DNSSettings.ServerZone | ? {$_.IsAutoCreated -eq $false})) {
        $ZoneProp = New-Object System.Object
        $ZoneProp | Add-Member -type NoteProperty -name Server -value $DC
        $ZoneProp | Add-Member -type NoteProperty -name ZoneName -value $Zone.ZoneName
        $ZoneProp | Add-Member -type NoteProperty -name ZoneType -value $Zone.ZoneType
        $ZoneProp | Add-Member -type NoteProperty -name DynamicUpdate -value $Zone.DynamicUpdate
        $ZoneProp | Add-Member -type NoteProperty -name DSIntegrated -value $Zone.IsDsIntegrated
        $ZoneProp | Add-Member -type NoteProperty -name ReverseLookup -value $Zone.IsReverseLookupZone
        $ZoneProp | Add-Member -type NoteProperty -name WINSEnabled -value $Zone.IsWinsEnabled
        $ZoneProp | Add-Member -type NoteProperty -name ReplicationScope -value $Zone.ReplicationScope
        $ZoneProp | Add-Member -type NoteProperty -name SecureSecondaries -value $Zone.SecureSecondaries
        $ZoneReport += $ZoneProp
    }
}
$ScavengeReport | ft -AutoSize
$RecurReport | ft -AutoSize
$ZoneReport | sort ZOneName, server | ft -AutoSize