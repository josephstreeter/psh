$xml = [xml] (Get-Content C:\scripts\CIS_Microsoft_Windows_2008_Server_Benchmark_v1.2.0-xccdf.xml)
$Rules = $xml.Benchmark.Group

$i = 0
$GroupCount = $rules.Group.Count
do
    {
    $x = 0
    $RuleCount = $rules.Group[$i].rule.Count
    ""
    $rules.Group[$i].title
    ""
    do
        {
        ""
        $rules.Group[$i].rule[$x].title
        ""
        $rules.Group[$i].rule[$x].description.p.code
        $x++
        }
    While ($x -lt $RuleCount)
    $i++
    }
while ($i -lt $GroupCount)


