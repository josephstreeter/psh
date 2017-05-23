$PropArray = @()
$scopes = Get-DhcpServerv4Scope -ComputerName dhcpprd01

foreach ($scope in $scopes)
    {    
    $Reservations = Get-DhcpServerv4Reservation -ComputerName dhcpprd01 -ScopeId $scope.ScopeId
    foreach ($Reservation in $Reservations)
        {
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name ScopeID -value $Reservation.ScopeID
        $Prop | Add-Member -type NoteProperty -name IpAddress -value $Reservation.IPAddress
        $Prop | Add-Member -type NoteProperty -name ClientID -value $Reservation.ClientID
        $Prop | Add-Member -type NoteProperty -name Name -value $Reservation.Name
        $Prop | Add-Member -type NoteProperty -name Type -value $Reservation.Type
        $PropArray += $Prop
       
        }
    }
$PropArray | ft -AutoSize