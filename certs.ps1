#'C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\makecert.exe'

#makecert -n "CN=PowerShell Local Certificate Root" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv root.pvk root.cer -ss Root -sr localMachine

#makecert -pe -n "CN=William PowerShell CSC" -ss MY -a sha1 -eku 1.3.6.1.5.5.7.3.3 -iv root.pvk -ic root.cer


$acert =(dir Cert:\CurrentUser\My -CodeSigningCert)[0]

Set-AuthenticodeSignature .\Powershellscripted.ps1 -Certificate $acert 

#$cert = New-SelfSignedCertificate -CertStoreLocation 
#Cert:\CurrentUser\My -Type CodeSigningCert -Subject "U2U Code Signing"

$functionDef = "function New-SelfSignedCertificateEx { ${function:New-SelfSignedCertificateEx}}"

$ScriptBlock = {
	param ($functionDef)
	
	. ([ScriptBlock]::Create($functionDef))
	
	$signedCertParams = @{
		'Subject' = "CN=$env:COMPUTERNAME"
		'SAN' = $env:COMPUTERNAME
		'EnhancedKeyUsage' = 'Document Encryption'
		'KeyUsage' = 'KeyEncipherment', 'DataEncipherment'
		'FriendlyName' = 'DSC Encryption Certifificate'
		'StoreLocation' = 'LocalMachine'
		'StoreName' = 'My'
		'ProviderName' = 'Microsoft Enhanced Cryptographic Provider v1.0'
		'PassThru' = $true
		'KeyLength' = 2048
		'AlgorithmName' = 'RSA'
		'SignatureAlgorithm' = 'SHA256'
	}
	New-SelfSignedCertificateEx @signedCertParams
}


Invoke-Command –ComputerName DESKTOP-I968M17 –ScriptBlock $ScriptBlock –ArgumentList $functionDef

