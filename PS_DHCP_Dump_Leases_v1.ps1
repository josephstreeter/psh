$PropArray = @()
$scopes = Get-DhcpServerv4Scope -ComputerName dhcpprd01

foreach ($scope in $scopes)
    {    
    $Leases = Get-DhcpServerv4Lease -ComputerName dhcpprd01 -ScopeId $scope.ScopeId
    foreach ($Lease in $Leases)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name ScopeID -value $Lease.ScopeID
        $Prop | Add-Member -type NoteProperty -name IpAddress -value $Lease.IPAddress
        $Prop | Add-Member -type NoteProperty -name ClientID -value $Lease.ClientID
        $Prop | Add-Member -type NoteProperty -name HostName -value $Lease.HostName
        $Prop | Add-Member -type NoteProperty -name AddressState -value $Lease.AddressState
        $PropArray += $Prop
        }
    }

$PropArray | ? {($_.AddressState -eq "InactiveReservation") -or ($_.AddressState -eq "ActiveReservation")} | group AddressState | % {$_.group} | group clientID | ? {$_.count -gt 1} | % {"";$_.group} | ft -AutoSize
$PropArray | ? {$_.AddressState -eq "Declined"} | ft -AutoSize