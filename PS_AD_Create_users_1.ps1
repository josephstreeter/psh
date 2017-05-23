$objOU=[ADSI]“LDAP://ou=user,dc=ds,dc=com“
$list=Import-Csv “c:\scripts\users.csv”

foreach($items in $list) {

$CN="cn="+$items.CN
$SN=$items.SN
$title=$items.title
$description=$items.description
$department=$items.department
#$streetAddress=$items.streetAddress
#$postalcode=$items.postalcode
#$telephoneNumber=$items.telephoneNumber
$givenName=$items.givenName
$company=$items.company
#$mail=$items.mail
#$homePhone=$items.homePhone
#$mobile=$items.mobile
#$userPrincipalName=$items.userPrincipalName
$Samaccountname=$items.Samaccountname

$objUser=$objOU.create(“user”,$cn)
$objUser.Put(“sAMAccountName”,$Samaccountname)
$objUser.put(“SN”,$SN)
$objUser.put(“Title”,$title)
$objUser.put(“Description”,$description)
$objUser.put(“department”,$department)
#$objUser.put(“streetAddress”,$streetAddress)
#$objUser.put("telephoneNumber",$telephoneNumber)
$objUser.put("givenName",$givenName)
$objUser.put("company",$company)
#$objUser.put("mail",$mail)
#$objUser.put("homePhone",$homePhone)
#$objUser.put("mobile",$mobile)
#$objUser.put("userPrincipalName",$userPrincipalName)
$objUser.setinfo()
$objUser.psbase.Invoke(“SetPassword”,”P@ssW0Rd”)
$objUser.psbase.InvokeSet(‘Accountdisabled’,$false)
$objUser.psbase.CommitChanges()
}
