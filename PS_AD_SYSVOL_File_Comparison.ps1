$Ref="MCDC3.MATC.Madison.Login"
$files=(Get-ChildItem \\$Ref\SYSVOL\MATC.Madison.Login\Policies\PolicyDefinitions) 

$DCs = (Get-ADDomainController -Filter * -Server txdc1).hostname
$Results=@()

foreach ($File in $Files)
    {
    $hash=@{}
    for ($i = 0; $i -lt $DCs.count; $i++)
        { 
        $a=$DCs[$i]
        $b=$(Get-Item \\$($DCs[$i])\SYSVOL\MATC.Madison.Login\Policies\PolicyDefinitions\$($file.Name))
        
        $hash.add($a,$b.LastWriteTime)
        }
    $Hash.add("FileName",$File.Name)

    $Results+=New-Object psobject -Property $hash                                          
    }

 $Results | Out-GridView