$Days = (Get-Date).AddDays(-30)

$Servers = Get-ADComputer -Filter {(operatingSystem -like "*Server*") -and (lastlogondate -gt $days) -and (-not(comment -eq "N"))} -pr * #| select -First 10

$i = $Servers.Count
$t = $i 

$PropArray = @()

foreach ($Server in $Servers)
    {
    "$i of $t"
    $i-- 
    #$Prop = New-Object System.Object
    If ($NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $Server.name -ErrorAction SilentlyContinue | where {$_.IPEnabled -eq “TRUE”})
        {
        Foreach($NIC in $NICs) 
	        {
            $Prop = New-Object System.Object
            $Prop | Add-Member -type NoteProperty -name Server -value $Server.name
            $Prop | Add-Member -type NoteProperty -name IPAddress -value $Server.IPv4Address
            $Prop | Add-Member -type NoteProperty -name Index -value $NIC.Index
            $Prop | Add-Member -type NoteProperty -name DomainSuffix -value $NIC.DNSDomain
            If ($NIC.DNSServerSearchOrder)
                {
                $Prop | Add-Member -type NoteProperty -name DNS1 -value $NIC.DNSServerSearchOrder[0]
                $Prop | Add-Member -type NoteProperty -name DNS2 -value $NIC.DNSServerSearchOrder[1]
                $Prop | Add-Member -type NoteProperty -name DNS3 -value $NIC.DNSServerSearchOrder[2]
                } 
                Else 
                {
                $Prop | Add-Member -type NoteProperty -name DNS1 -value "None"
                $Prop | Add-Member -type NoteProperty -name DNS2 -value "None"
                $Prop | Add-Member -type NoteProperty -name DNS3 -value "None"
                }
            $Prop | Add-Member -type NoteProperty -name DHCPEnabled -value $NIC.DHCPEnabled
            $Prop | Add-Member -type NoteProperty -name RegDomain -value $NIC.DomainDNSRegistrationEnabled
            #$Prop | Add-Member -type NoteProperty -name SearchOrder -value $(Clear-Variable SearchOrder ; $nic.DNSDomainSuffixSearchOrder | % { $SearchOrder = $SearchOrder + " " + $_ } ; $SearchOrder.trim())
            $Prop | Add-Member -type NoteProperty -name DynReg -value $NIC.FullDNSRegistrationEnabled
            $Prop | Add-Member -type NoteProperty -name LMHost -value $NIC.WINSEnableLMHostsLookup
            $Prop | Add-Member -type NoteProperty -name NetBIOS -value $NIC.TcpipNetbiosOptions
            $PropArray += $Prop
            }
        }
        Else
        {
        Set-ADComputer $Server.name -add @{comment="N"}
        }
    }

$PropArray | ft * -AutoSize

$PropArray | ? { ($_.dns1 -match ".115") -or ($_.dns2 -match ".115") -or ($_.dns3 -match ".115") } | ft * -AutoSize