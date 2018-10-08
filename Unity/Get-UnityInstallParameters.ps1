
function Get-UnityInstallParameters {

	param (
		[Parameter(Mandatory=$true)][string]$Version
	)

	$installParametersForKnownVersions = @{

		"2018.2.5f1" = [PSCustomObject]@{
			InstallerDownloadUrl = "https://netstorage.unity3d.com/unity/3071d1717b71/Windows64EditorInstaller/UnitySetup64-2018.2.5f1.exe";
			InstallerFileName = "UnitySetup64-2018.2.5f1.exe";
			UnityVersionName = "Unity 2018.2.5f1"
		},

		"2018.2.6f1" = [PSCustomObject]@{
			InstallerDownloadUrl = "https://netstorage.unity3d.com/unity/c591d9a97a0b/Windows64EditorInstaller/UnitySetup64-2018.2.6f1.exe";
			InstallerFileName = "UnitySetup64-2018.2.6f1.exe";
			UnityVersionName = "Unity 2018.2.6f1"
		}

		"2018.2.7f1" = [PSCustomObject]@{
			InstallerDownloadUrl = "https://netstorage.unity3d.com/unity/4ebd28dd9664/Windows64EditorInstaller/UnitySetup64-2018.2.7f1.exe";
			InstallerFileName = "UnitySetup64-2018.2.7f1.exe";
			UnityVersionName = "Unity 2018.2.7f1"
		}

	}

	if (!$installParametersForKnownVersions.ContainsKey($Version)) {
		$knownVersions = $installParametersForKnownVersions.keys -join ", "
		throw "Unknown Unity version $Version. The versions which have install parameters specified are $knownVersions."
	}
	else {
		return $installParametersForKnownVersions[$Version]
	}
}	
