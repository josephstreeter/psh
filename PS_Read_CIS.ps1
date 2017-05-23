$xml = [xml] (Get-Content C:\scripts\tablet\CIS_Microsoft_Windows_2008_Server_Benchmark_v1.2.0-xccdf.xml)
$Rules = $xml.Benchmark.Group.Group

foreach ($rule in $rules)
    {
    "`n`n`n`n-----------------------"
    $Rule.title
    "-----------------------"
    for ($i = 0; $i -lt $Rule.Value.count; $i++)
        { 
        "`n######################################################################"
        $rule.value[$i].Title + " ($i)"
        "######################################################################"
        #"Description " + $rule.value[$i].description
        "Code        " + $rule.rule[$i].description.p.code
        "Operator    " + $rule.value[$i].operator
        "Value:"
        for ($a = 0; $a -lt $Rule.Value[$i].value.count; $a++)
            {
            "`tType   " + $Rule.Value[$i].value[$a].selector + " `t " + $Rule.Value[$i].value[$a].'#text'
            }
        }    
    }




    <#$rules[0].value[0].description
    $rules[0].rule[0].description.p.code
    $rules[0].value[0].operator
    $rules[0].value[0].value
    #>