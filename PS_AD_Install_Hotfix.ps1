function Set-Registry($Path,$Value,$Data)
    {
    If(!(Test-Path $Path))
        {
        "Adding the value the registry"
        New-Item `
            -Path $Path `
            -Force | Out-Null
        
        New-ItemProperty `
            -Path $Path `
            -Name $Value `
            -Value $Data `
            -PropertyType DWORD -Force | Out-Null
        }
    Else 
        {
        if ((Get-ItemProperty -Path $Path).$value -eq 0)
            {
            "Registry already configured"
            }
        Else
            {
            "Updating the registry value"
            New-ItemProperty `
                -Path $Path `
                -Name $Value `
                -Value $Data `
                -PropertyType DWORD -Force | Out-Null
            }
        }
    }

function Resume-Replication()
    {
    invoke-expression "wmic /namespace:\\root\microsoftdfs pathdfsrVolumeConfig where ‘volumeGuid="F1CF316E-6A40-11E2-A826-00155D41C919"’ call ResumeReplication"
    }

function install-hotfix($hotfix)
    {
    if (!(Test-Path C:\Scripts))
        {
        New-Item -Path c:\ -Name Scripts -ItemType Directory
        }
    if (Test-Path $hotfix)
        {
        Invoke-Expression "wusa $hotfix /quiet /warnrestart:10 /log:c:\scripts\hotfix.log"
        }
    }

$Path = "HKLM:\System\CurrentControlSet\Services\DFSR\Parameters"
$Value = "StopReplicationOnAutoRecovery"
$Data = "0"
#$hotfix = "C:\Windows\SYSVOL\sysvol\matc.ts.test\scripts\Windows6.1-KB2780453-v2-x64.msu"
$hotfix = "\\testmdc03\netlogon\Windows6.1-KB2780453-v2-x64.msu"

# install-hotfix $hotfix
# Set-Registry $Path $Value $Data