$Report = @()
$tests = dcdiag /s:$((Get-addomain).pdcemulator)

$Results = $tests | Select-String -Pattern '(?s)test .*?' | Select-String "omitted" -notmatch | Select-String "skip" -NotMatch | Select-String "\*" -NotMatch | % {$_.tostring()}

Foreach ($result in $results) {

    $Report += New-object PSObject -Property @{
        Host = $result.tostring().split(" ")[10]
        Test = $result.tostring().split(" ")[13]
        Result = $result.tostring().split(" ")[11]
        }
    }

$Report | select Test,Result,Host -Unique | sort host | ft -AutoSize