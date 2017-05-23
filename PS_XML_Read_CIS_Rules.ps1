$xccdf = [xml] (Get-Content C:\scripts\CIS_Microsoft_Windows_2008_Server_Benchmark_v1.2.0-xccdf.xml)
$Rules = $xccdf.Benchmark.Group.Group.value

$Rules[10].description
$Rules[10].Value

$x = $rules.count ; $i = 0 ; Do {"";"($i) " + $rules[$i].description;"_________________";$rules[$i].value;$i++} while ($i -lt $x)  

<#$oval = [xml] (Get-Content C:\scripts\CIS_Microsoft_Windows_2008_Server_Benchmark_v1.2.0-oval.xml)
$checks = $oval.oval_definitions

$xsd = [xml] (Get-Content C:\scripts\windows-definitions-schema.xsd)
$def = $xsd#>
