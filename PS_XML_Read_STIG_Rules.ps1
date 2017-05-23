$xccdf = [xml](Get-Content "C:\Users\jstreeter\OneDrive\Documents\AD Docs\DoD\STIGs\u_active_directory_manual_v2r1_stig_\u_active_directory_domain_v2r1_manual-xccdf.xml")

$Title = $xccdf.Benchmark.Group.group.value

$x = $Title.count
$i = 0

Do 
    {
    "($i) " + $Title[$i].title
    "____________________"
    $Title[$i].value
    ""
    $i++
    } 
While ($i -lt $x)