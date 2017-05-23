$objForest = Get-ADForest
	foreach ($strDomain in $objForest.Domains)
		{
		$objDomain = Get-ADDomain $strDomain
		Write-Host "DNS Name: " $objDomain.DNSRoot
		Write-Host ""
		Write-Host "Global Catalog Servers:" 
			foreach ($objGC in $objForest.GlobalCatalogs)
				{
				Write-Host "	" $objGC
				}
		Write-Host ""
		Write-Host "Domain Controllers:"
			$colDCs = $objDomain.ReplicaDirectoryServers
			foreach ($objDC in $objDomain.ReplicaDirectoryServers)
					{
					Write-Host "	" $objDC
					}
		Write-Host ""			
		Write-Host "RODCs: "
			foreach ($objRODC in $objDomain.ReadOnlyReplicaDirectoryServers)
					{
					Write-Host "	" $objRODC
					}
		Write-Host ""
		Write-Host "PDC Emulator: " $objDomain.PDCEmulator
			$strPDCE = $objDomain.PDCEmulator
		Write-Host ""
		Write-Host "##### DCDIAG Tests #####"
		DCDIAG ($strPDCE, $colDCs)
		}

function DCDiag ($strPDCE, $colDCs)
	{
	foreach ($strDC in $colDC)
		{
		Write-Host "" $strDC
		#invoke-expression -Command "dcdiag.exe /test:dns"
		}
	}