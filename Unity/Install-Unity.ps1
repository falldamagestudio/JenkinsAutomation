
function Install-Unity {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$Version,
		[Parameter(Mandatory=$true)][string[]]$Components
	)

	$unityVersionName = "Unity {0}" -f $Version

	$installBaseDir = "C:\Program Files"

	$installDir = Join-Path -Path $installBaseDir -ChildPath $unityVersionName
		
	echo "Downloading/running $unityVersionName installers..."

	# Ensure there is a temp directory

	. (Join-Path -Path $PSScriptRoot -ChildPath "..\Helpers\New-TempDir.ps1")
	$targetTempDir = New-TempDir $TargetSession

	# Get download URLs
	
	$installerJsonURL = "https://falldamagestudio.github.io/UnityDownloadURLs/installers/{0}.json" -f $Version
	$installerJson = Invoke-WebRequest -Uri $installerJsonURL | ConvertFrom-Json

	foreach ($component in $Components)
	{
		$installerDownloadUrl = $installerJson.$component
		$installerFileName = "Unity_{0}_{1}.exe" -f $component,$Version
		
		# Download installer

		$targetDownloadLocation = Join-Path -Path $targetTempDir -ChildPath $installerFileName

		if (!(Invoke-Command -Session $targetSession -ScriptBlock { Test-Path -Path $using:targetDownloadLocation })) {
			echo "Downloading $unityVersionName $component..."
			Invoke-Command -Session $targetSession -ScriptBlock { Invoke-WebRequest -Uri $using:installerDownloadUrl -OutFile $using:targetDownloadLocation }
		}
		
		# Run installer

		echo "Installing $unityVersionName $component..."
		Invoke-Command -Session $targetSession -ScriptBlock { Start-Process -FilePath $using:targetDownloadLocation -ArgumentList "/S","/D=$using:installDir" -Wait }
	}
}
