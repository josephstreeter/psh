Function Get-ZoneAging
    {
    $ServerScaveging = @()
    foreach ($DC in $DCs) 
        {
        $ServerConfig = Get-DnsServerScavenging -computer $DC.hostname -ea SilentlyContinue
        $ZoneConfig = Get-DnsServerZoneAging -ComputerName $DC -Name "MATC.Madison.login" -ea SilentlyContinue

        $SS = New-Object System.Object
        $SS | Add-Member -type NoteProperty -name Host -value $DC.hostname
        $SS | Add-Member -type NoteProperty -name ScavengingState -value $ServerConfig.ScavengingState
        $SS | Add-Member -type NoteProperty -name ScavengingInterval -value $ServerConfig.ScavengingInterval
        $SS | Add-Member -type NoteProperty -name NoRefreshInterval -value $ServerConfig.NoRefreshInterval
        $SS | Add-Member -type NoteProperty -name RefreshInterval -value $ServerConfig.RefreshInterval
        $SS | Add-Member -type NoteProperty -name LastScavengTime -value $ServerConfig.LastScavengeTime
        $SS | Add-Member -type NoteProperty -name ZoneName -value "MATC.Madison.login"
        $SS | Add-Member -type NoteProperty -name ZoneAgingEnabled -value $ZoneConfig.AgingEnabled
        $SS | Add-Member -type NoteProperty -name ZoneRefreshInterval -value $ZoneConfig.RefreshInterval
        $SS | Add-Member -type NoteProperty -name ZoneNoRefreshInterval -value $ZoneConfig.NoRefreshInterval
        $ServerScaveging += $SS   
        }
    Return $ServerScaveging
    }

Function Get-DNSForwarders
    {
    $Forwaders = @()
    foreach ($DC in $DCs) 
        {
        $ServerForwarders = (Get-DnsServer -ComputerName $DC.hostname -WarningAction Ignore ).serverforwarder.ipaddress.ipaddressToString
        
        $FWD = New-Object System.Object
        $FWD | Add-Member -type NoteProperty -name Host -value $DC.hostname
        if ($ServerForwarders) 
            {
            $FWD | Add-Member -type NoteProperty -name PrimaryForwader -value $ServerForwarders[0]
            $FWD | Add-Member -type NoteProperty -name SecondaryForwarder -value $ServerForwarders[1]
            }
            Else
            {
            $FWD | Add-Member -type NoteProperty -name PrimaryForwader -value "None"
            $FWD | Add-Member -type NoteProperty -name SecondaryForwarder -value "None"
            }
        $Forwaders += $FWD   
        }
    Return $Forwaders
    }

Function Set-DNSForwarders
    {
    $Forwaders = @()
    foreach ($DC in $DCs) 
        {
        $ServerForwarders = (Get-DnsServer -ComputerName $DC.hostname -WarningAction Ignore ).serverforwarder.ipaddress.ipaddressToString
        if (-not ($ServerForwarders))
            {
            Set-DnsServerForwarder -ComputerName $DC.Hostname -IPAddress "10.39.0.112","10.39.0.114" -PassThru
            }
        }
    }

$DCs = Get-ADDomainController -Filter 'hostname -ne "MCRODC.MATC.Madison.Login"'

#Get-ZoneAging | Ft -AutoSize
Get-DNSForwarders | ft -AutoSize
#Set-DNSForwarders