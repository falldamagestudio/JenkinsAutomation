
function New-PSSession-GoogleCloudHost {

	param (
		[Parameter(Mandatory=$true)][string]$TargetIp,
		[Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credential
	)

	# Connect

	$targetSession = New-PSSession -ComputerName $TargetIp -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $Credential
	
	return $targetSession
}
