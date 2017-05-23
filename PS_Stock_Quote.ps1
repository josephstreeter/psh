<#
.Synopsis
   Retrieve stock information
.DESCRIPTION
   Retrieve stock information 
.PARAMETER Symbol
  Stock symbol of one or more companies
.EXAMPLE
 Get-StockInfo -Symbol MSFT,INTC
.LINK
    
.NOTES
  Version 1.0, by Alex Verboon
#>
  
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage= 'Stock Symbol for the company')]
            [String[]]$Symbol
)
 
begin{}
process{
 
if ([string]::IsNullOrEmpty($Symbol))
    {Write-Output "You must provide a Symbol"
    Exit}
   
ForEach ($stock in $Symbol)
    {
    $sq = Invoke-WebRequest -uri http://www.webservicex.net/stockquote.asmx/GetQuote?symbol=$stock
    $sqdetail = $sq.DocumentElement.'#text'
    $sqdetail.StockQuotes.stocK
    }
}
 
End{}
