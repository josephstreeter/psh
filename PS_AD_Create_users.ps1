
$objOU = [ADSI]"LDAP://OU=user,dc=ds,dc=wisc,dc=edu"

$list = Import-Csv c:\scripts\users.csv

foreach ($item in $list )
{
write-host $item.givenName + "." + $item.sn
$objUser = $objOU.Create("user","cn=" + $item.givenName + "." + $item.sn)
$objUser.Put(“sAMAccountName”,$item.givenName + "." + $item.sn)
$objUser.Put("sn",$item.sn)
$objUser.Put("givenName",$item.givenName)
$objUser.Put("displayName",$item.sn + ", " + $item.givenName)
$objUser.Put("description",$item.description)
$objUser.Put("physicalDeliveryOfficeName",$item.physicalDeliveryOfficeName)
$objUser.Put("title",$item.title)
$objUser.Put("department",$item.department)
$objUser.Put("mail",$item.mail)
$objUser.Put("telephoneNumber",$item.telephoneNumber)
$objUser.Put("streetaddress",$item.streetaddress)
$objUser.Put("i",$item.i)
$objUser.Put("st",$item.st)
$objUser.Put("postalcode",$item.postalcode)
#$objUser.Put("altSecurityIdentities", "Kerberos:"+$item.givenName+"."+$item.sn+"@LOGIN.WISC.EDU")
$objUser.SetInfo()
}