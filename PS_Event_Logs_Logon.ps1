﻿$List = @()
foreach ($DC in $(Get-ADDomainController -Filter {name -notlike "*RODC*"}).hostname)
    {
    $DC
    $Events = Get-WinEvent -ComputerName $dc -FilterHashtable @{Logname='Security';Id=4624} #-MaxEvents 100
    ForEach ($Event in $Events) 
        {
        $EL = New-Object -type system.object
        $eventXML = [xml]$Event.ToXml()
        $EL | Add-Member -MemberType NoteProperty -Force -Name "DomainController" -value $DC
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[0].name -value $eventxml.Event.EventData.data[0].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[1].name -value $eventxml.Event.EventData.data[1].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[2].name -value $eventxml.Event.EventData.data[2].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[3].name -value $eventxml.Event.EventData.data[3].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[4].name -value $eventxml.Event.EventData.data[4].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[5].name -value $eventxml.Event.EventData.data[5].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[6].name -value $eventxml.Event.EventData.data[6].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[7].name -value $eventxml.Event.EventData.data[7].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[8].name -Value ($eventxml.Event.EventData.data[8].'#text').split(",")[0]
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[9].name -value $eventxml.Event.EventData.data[9].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[10].name -value $eventxml.Event.EventData.data[10].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[11].name -value $eventxml.Event.EventData.data[11].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[12].name -value $eventxml.Event.EventData.data[12].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[13].name -value $eventxml.Event.EventData.data[13].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[14].name -value $eventxml.Event.EventData.data[14].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[15].name -value $eventxml.Event.EventData.data[15].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[17].name -value $eventxml.Event.EventData.data[16].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[18].name -value $eventxml.Event.EventData.data[18].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name $eventxml.Event.EventData.data[19].name -value $eventxml.Event.EventData.data[19].'#text'
        $EL | Add-Member -MemberType NoteProperty -Force -Name SystemTime -value ($eventXML.Event.System.TimeCreated.SystemTime).Split(".")[0]
        $List += $EL
        }

    $file = $env:computername + ".txt"
    }

#$list  | ? {($_.TargetUserName -notlike "*$")} | ft -AutoSize 
$list | ? {$_.TargetUserName -notlike "*$"} | ft TargetUserName,SubjectUserName,WorkstationName,ipaddress,DomainController
<#
Name                                #text                                                                                                                                           
----                                                                                                                                              -----                                                                                                                                           
0  SubjectUserSid                   S-1-0-0                                                                                                                                         
1  SubjectUserName                                                                                                                                   -                                                                                                                                               
2  SubjectDomainName                                                                                                                                 -                                                                                                                                               
3  SubjectLogonId                   0x0                                                                                                                                             
4  TargetUserSid                    S-1-0-0                                                                                                                                         
5  TargetUserName                   W170-29667L$                                                                                                                                    
6  TargetDomainName                 MATCMADISON                                                                                                                                     
7  Status                           0xc000006d                                                                                                                                      
8  FailureReason                    %%2313                                                                                                                                          
9  SubStatus                        0xc000006a                                                                                                                                      
10 LogonType                        3                                                                                                                                               
11 LogonProcessName                 NtLmSsp                                                                                                                                         
12 AuthenticationPackageName        NTLM                                                                                                                                            
13 WorkstationName                  W170-29667L                                                                                                                                     
14 TransmittedServices                                                                                                                               -                                                                                                                                               
15 LmPackageName                                                                                                                                     -                                                                                                                                               
16 KeyLength                        0                                                                                                                                               
17 ProcessId                        0x0                                                                                                                                             
18 ProcessName                                                                                                                                       -                                                                                                                                               
19 IpAddress                        10.97.68.29                                                                                                                                     
20 IpPort                           50420    #>