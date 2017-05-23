<#
Remove-DhcpServerv4ExclusionRange -ScopeId <IPAddress> -StartRange <IPAddress> -EndRange <IPAddress> -ComputerName <String> -Passthru -Confirm $False 
Add-DhcpServerv4ExclusionRange -ScopeId <IPAddress> -StartRange <IPAddress> -EndRange <IPAddress> -ComputerName <String> -PassThru -Confirm $False
#>

$scopes = Import-Csv .\dhcp_scope_export.csv #| select -First 15

foreach ($scope in $scopes)
    {    
    "Remove $scope.ScopeId"
    Remove-DhcpServerv4ExclusionRange -ScopeId $scope.ScopeId -StartRange $scope.ExlusionStart -EndRange $scope.ExlusionEnd -ComputerName DHCPPRD01 -Passthru -Confirm:$False
    "Add $scope.ScopeId"
    Add-DhcpServerv4ExclusionRange -ScopeId $scope.ScopeId -StartRange $scope.NewExlusionStart -EndRange $scope.NewExlusionEnd -ComputerName DHCPPRD01 -Passthru -Confirm:$False
    }