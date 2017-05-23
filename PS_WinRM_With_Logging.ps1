<#
Authror - Streeter, Joseph A
Pirpose - Scripts Template
Date - Today
#>

Begin
    {
    # Import Modules
    Import-Module ActiveDirectory
    
    # Set Global Variables
    $Global:date = get-date -uformat "%Y-%m-%d"
    $Global:FilePath = "C:\Scripts"
    $Global:Logfile = $FilePath + "\"+$date+"-logfile.txt"

    Function Log($EntryType,$entry)
        {
        $datetime = get-date -uformat "%Y-%m-%d-%H:%m:%S"
        if (-not(get-item $Logfile -ea 0))
            {
            $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile
            }
            Else
            {
            $DateTime+"-"+$EntryType+"-"+$Entry | Out-File $Logfile -Append
            }
        }
    
    Function Test-Server($DNSHostName)
        {
        If (Resolve-DnsName $DNSHostName -ea 0)
            {
            Return $True
            }
            Else
            {
            Return $False
            }
        }
    }

Process
    {
    $Servers=Get-ADComputer -Filter {(OperatingSystem -like "*Server*")} -SearchBase "OU=Servers,DC=MATC,DC=Madison,DC=Login"
    
    Log "Informational" "Begining new run on $($Servers.count) Hosts"
    
    foreach ($Server in $Servers)
        {
        if (Test-Server $Server.DNSHostName)
            {
            Log "Success" "Resolved $($Server.DNSHostName) via DNS"
            If (Invoke-Command -ComputerName $Server.DNSHostName -ScriptBlock {Get-Item c:\})
                {Log "Success" "Connected via WinRM to $($Server.DNSHostName)"}
                Else
                {Log "Error" "Failed to connect via WinRM to $($Server.DNSHostName)"}
            }
            Else
            {
            Log "Error" "Failed to resolve $($Server.DNSHostName)"
            }
        }
    }

End
    {

    }