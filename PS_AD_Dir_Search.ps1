<#
.Synopsis
   Searches Active Directory without the 
   Active Directory Module
.DESCRIPTION
   Searches Active Directory without the 
   Active Directory Module being installed
   as part of RSAT
.EXAMPLE
   Search for a user with the CN "juser"
   Query-ADObject -Filter "(&(objectClass=user)(cn=juser))"
.EXAMPLE
   Search for all users with a CN that starts with "jus"
   Query-ADObject -Filter "(&(objectClass=user)(cn=jus*))"
.EXAMPLE
   Query all members of a group with a CN that equals "Dept_Group" and query each member for its attributes.
    $Users=(Query-ADObject -filter "(&(cn=Dept_Group))").member | % {Query-ADObject -Filter "(&(distinguishedname=$_))"}
    foreach ($User in $Users) {"Username: $($User.name) Description: $($User.description)"}
.NOTES
   LDAP Filter Syntax
   https://social.technet.microsoft.com/wiki/contents/articles/5392.active-directory-ldap-syntax-filters.aspx
.FUNCTIONALITY
   The functionality that best describes this cmdlet
    
#>

function Query-ADObject()
    {
    Param
    (
    [Parameter(Mandatory=$true)][string]$Filter,
    [Parameter(Mandatory=$false)][string]$Base,
    [Parameter(Mandatory=$false)][string]$Scope ="subtree"
    )
    
    $Searcher=New-Object DirectoryServices.DirectorySearcher 

    $Searcher.Filter = $Filter
    $Searcher.PageSize = 100
    $Searcher.SearchScope = $Scope
    if ($Base)
        {
        $Searcher.SearchRoot = $Base
        }
    $Results=$Searcher.FindAll()
    
    Return $Results.Properties
    }