$Service="EventLog"
$Services=@()
[System.Collections.Generic.List[System.String]]$Restart=@()

Function List-Services ($Service)
    {
    $DepServices=Get-Service $Service | select -ExpandProperty DependentServices

    Return $DepServices
    }

$Services+=Get-Service $Service

$Services+=List-Services $Service

foreach ($Service in $Services)
    {
    $Services+=List-Services $Service.Name
    }

$Services | select -Unique | ? {$_.status -eq "running"} | % {$Restart.add($_.name)}

$Restart
$Restart.Reverse()
$Restart