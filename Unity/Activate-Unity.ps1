
function Activate-Unity {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$Version,
		[Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$UnityCredential,
		[Parameter(Mandatory=$true)][string]$Serial
	)

	$installBaseDir = "C:\Program Files"
	$unityVersionName = "Unity {0}" -f $Version

	$applicationRegistryKey = "HKCU:\Software\Unity Technologies\Installer\Unity"
	$applicationRegistryVersion = $Version

	# Fail if the exact version of Unity is not found on the machine

	if (!(Invoke-Command -Session $targetSession -ScriptBlock { (Test-Path -Path $using:applicationRegistryKey) -and ((Get-ItemProperty $using:applicationRegistryKey).Version -eq $using:applicationRegistryVersion) })) {
		Throw "$unityVersionName not found on machine"
	}
	else {
		$unityEditorExecutableLocation = (Join-Path -Path $installBaseDir -ChildPath $unityVersionName | Join-Path -ChildPath "Editor/Unity.exe")

		$username = $UnityCredential.GetNetworkCredential().username
		$password = $UnityCredential.GetNetworkCredential().password
		
		echo "Activating Unity license..."
		Invoke-Command -Session $targetSession -ScriptBlock { Start-Process -FilePath $using:unityEditorExecutableLocation -ArgumentList "-quit","-batchmode","-serial","$using:Serial","-username","$using:username","-password","$using:password" -Wait }
	}
}