
function Get-PlasticInstallParameters {

	param (
		[Parameter(Mandatory=$true)][string]$Version
	)

	$installParametersForKnownVersions = @{

		"7.0.16.2562" = [PSCustomObject]@{
			InstallerDownloadUrl = "https://www.plasticscm.com/download/downloadinstaller/7.0.16.2562/plasticscm/windows/cloudedition?Flags=None";
			InstallerFileName = "PlasticSCM-7.0.16.2562-windows-cloud-installer.exe";
			ApplicationRegistryKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Codice Software Plastic SCM 7.0.16.2562"
		}

	}

	if (!$installParametersForKnownVersions.ContainsKey($Version)) {
		$knownVersions = $installParametersForKnownVersions.keys -join ", "
		throw "Unknown Plastic version $Version. The versions which have install parameters specified are $knownVersions."
	}
	else {
		return $installParametersForKnownVersions[$Version]
	}
}	
