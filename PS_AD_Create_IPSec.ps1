<#
$CADS = "TCDC1,10.39.0.111", "MDC1,10.39.0.110", "MDC2,10.39.0.113", "MDC3,10.39.0.114", "MDC5,10.39.0.112", "DTDC02,10.102.1.111", "VDI-DC01,10.181.255.76","VDI-DC02,10.181.255.77", "MDCSYNC,10.32.1.110"
$CUSTOMER = "IDMDCPRD01,198.150.177.67","IDMDCPRD02,198.150.177.68"
$CADS = "TESTDC01,10.39.0.50", "TESTDC02,10.39.0.51","TESTMDC01,10.39.0.150", "TESTMDC02,10.39.0.151","TESTMDC03,10.39.0.152","TESTMDC04,10.39.0.153", "TESTSITEMDC,10.32.1.150", "TESTRODC1,198.150.17.61"
$CUSTOMER = "IDMDCTST01,198.150.17.65","IDMDCTST02,198.150.17.66"
#>


$CADS = "TXDC1,10.39.0.111", "MDC1,10.39.0.110", "MDC2,10.39.0.113", "MDC3,10.39.0.114", "MDC5,10.39.0.112", "DTDC02,10.102.1.111", "VDI-DC01,10.181.255.76","VDI-DC02,10.181.255.77", "MDCSYNC,10.32.1.110"
$CUSTOMER = "IDMDCPRD01,198.150.17.67","IDMDCPRD02,198.150.17.68",,"IDMDCPRD02,198.150.17.33"


"" | out-file C:\Scripts\netsh-ipsec.txt
"netsh ipsec static add policy name='AD Trusts' description='AD Forest Trust traffic' mmpfs='no' mmlifetime='10' activatedefaultrule='no' pollinginterval='5' assign=no mmsec='3DES-SHA1-2'" | out-file C:\Scripts\netsh-ipsec.txt

"netsh ipsec static add filteraction name='ESP-3DES-SHA1-0-3600' description='Require ESP 3DES/SHA1, no inbound clear, no fallback to clear, No PFS' qmpfs=no inpass=no soft=no action=negotiate qmsecmethods='ESP[3DES,SHA1]:3600s'" | out-file -append C:\Scripts\netsh-ipsec.txt
"netsh ipsec static add filterlist DomainControllers" | out-file -append C:\Scripts\netsh-ipsec.txt

foreach ($CADSDC in $CADS) {foreach ($CUSTOMERDC in $CUSTOMER){"netsh ipsec static add filter filterlist=DomainControllers description="+$CADSDC.split(",")[0]+"-"+$CUSTOMERDC.split(",")[0]+" srcaddr="+$CADSDC.split(",")[1]+" dstaddr="+$CUSTOMERDC.split(",")[1] | out-file -append C:\Scripts\netsh-ipsec.txt}}

"netsh ipsec static add rule name='DC-DC' policy='AD Trusts' filterlist='Domain Controllers' filteraction='ESP-3DES-SHA1-0-3600' kerberos='no' psk='my complex password'" | out-file -append C:\Scripts\netsh-ipsec.txt
