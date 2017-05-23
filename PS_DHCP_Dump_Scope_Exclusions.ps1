Function Get-Scopes {
$PropArray = @()
$scopes = Get-DhcpServerv4Scope -ComputerName dhcpprd01

foreach ($scope in $scopes)
    {    
    $Exclusions = Get-DhcpServerv4ExclusionRange -ComputerName dhcpprd01 -ScopeId $scope.ScopeId
    foreach ($Exclusion in $Exclusions)
        {
        ""
        $Exclusion.StartRange.IPAddressToString
        $Exclusion.EndRange.IPAddressToString
        
        $Prop = New-Object System.Object
        $Prop | Add-Member -type NoteProperty -name ScopeID -value $Scope.ScopeID
        $Prop | Add-Member -type NoteProperty -name SubnetMask -value $Scope.SubnetMask
        $Prop | Add-Member -type NoteProperty -name Name -value $Scope.Name
        $Prop | Add-Member -type NoteProperty -name State -value $Scope.State
        $Prop | Add-Member -type NoteProperty -name ScopeStart -value $Scope.StartRange
        $Prop | Add-Member -type NoteProperty -name ScopeEnd -value $Scope.EndRange
        $Prop | Add-Member -type NoteProperty -name ExlusionStart -value $Exclusion.StartRange.IPAddressToString
        $Prop | Add-Member -type NoteProperty -name ExlusionEnd -value $Exclusion.EndRange.IPAddressToString
        $Prop | Add-Member -type NoteProperty -name LeaseTime -value $Scope.LeaseDuration
        $PropArray += $Prop
       
        }
    }
$PropArray | ConvertTo-Csv | Out-File C:\Scripts\dhcp_scope_export1.csv
}


function Replace-Exclusions {
$scopes = Import-Csv .\dhcp_scope_export.csv #| select -First 15

foreach ($scope in $scopes)
    {    
    "Remove $scope.ScopeId"
    Remove-DhcpServerv4ExclusionRange -ScopeId $scope.ScopeId -StartRange $scope.ExlusionStart -EndRange $scope.ExlusionEnd -ComputerName DHCPPRD01 -Passthru -Confirm:$False
    "Add $scope.ScopeId"
    Add-DhcpServerv4ExclusionRange -ScopeId $scope.ScopeId -StartRange $scope.NewExlusionStart -EndRange $scope.NewExlusionEnd -ComputerName DHCPPRD01 -Passthru -Confirm:$False
    }
}

Get-Scopes