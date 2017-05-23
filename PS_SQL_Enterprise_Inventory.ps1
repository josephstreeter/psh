$Servers = Get-ADComputer -f * -SearchBase "OU=Servers,DC=MATC,DC=Madison,DC=Login" | sort name

Function Query-Instance($Server)
    {
    $Instances = @()
    [array]$captions = gwmi win32_service -computerName $Server | ?{$_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe"} | %{$_.Caption}
    
    foreach ($caption in $captions) 
        {
        if ($caption -match "MSSQLSERVER") 
            {
            $Instances += $Server #"MSSQLSERVER"
            } 
        else 
            {
            $temp = $caption | %{$_.split(" ")[-1]} | %{$_.trimStart("(")} | %{$_.trimEnd(")")}
            $Instances += "$Server\$temp"
            }
        }
    return $Instances
    }

Function Query-DB($Instance)
    {
    [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $sqlServer = New-Object("Microsoft.SqlServer.Management.Smo.Server") $Instance
    foreach($sqlDatabase in $sqlServer.databases) 
        {
        $sqlDatabase
        }
    }


$Report=@()
foreach ($Server in $Servers)
    {
    if ($Instances = Query-Instance $Server.Name)
        {
        foreach ($Instance in $Instances)
            {
            #"$($Server.name) ($($Instance))"
            $DBs = Query-DB $Instance
            foreach ($DB in $DBs)
                {
                if (($DB.Database -ne "master") -or ($_.database -ne "model") -or ($_.database -ne "tempdb"))
                    {
                    $Report+=New-Object psobject -Property @{
                        "Instance"=$Instance
                        "Database"=$DB.Name
                        }
                    }
                }
            }
        }    
    }

$Report | ft
$Report | ConvertTo-Csv | Out-File C:\Scripts\database_inventory1.csv