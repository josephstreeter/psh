param(
    [string]   $ComputerName = '.',
    [string[]] $MaName       = $null,
    [string[]] $RunProfile   = $null
)

process {
    Get-WmiObject -Class 'MIIS_RunHistory' -Namespace 'root\MicrosoftIdentityIntegrationServer' -Filter 'RunStatus != "in-progress"' `
        |? { ([int]$MaName.Count -eq 0 -or $MaName -contains $_.MaName) -and ([int]$RunProfile.Count -eq 0 -or $RunProfile -contains $_.RunProfile) } `
        | Select-Object -Property MaName,RunProfile,@{Name='RunTime';Expression={[DateTime]::Parse($_.RunEndTime).Subtract([DateTime]$_.RunStartTime).Ticks}} `
        | Group-Object -Property MaName,RunProfile `
        | Sort-Object -Property Name `
        | Select-Object -Property *,@{Name='RunTimeStatistics';Expression={$_.Group |% {$_.RunTime} | Measure-Object -Average -Minimum -Maximum}} `
        | Select-Object -Property @(
            @{Name='MaName';Expression={$_.Group | Select-Object -Expand MaName -First 1}},
            @{Name='RunProfile';Expression={$_.Group | Select-Object -Expand RunProfile -First 1}},
            @{Name='Count';Expression={$_.Count}},
            @{Name='Average';Expression={[TimeSpan]::FromTicks($_.RunTimeStatistics.Average)}},
            @{Name='Minimum';Expression={[TimeSpan]::FromTicks($_.RunTimeStatistics.Minimum)}},
            @{Name='Maximum';Expression={[TimeSpan]::FromTicks($_.RunTimeStatistics.Maximum)}}
          ) | ft -auto
} 