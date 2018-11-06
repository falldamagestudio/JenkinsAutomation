
function Install-Java {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession
	)

	$jreDownloadUrl = "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jre-8u192-windows-x64.exe"
	
	$applicationRegistryKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F64180181F0}"

	# Skip if the exact same version of the application is already installed
	
	if (!(Invoke-Command -Session $TargetSession -ScriptBlock { Test-Path -Path $using:applicationRegistryKey })) {

		# Ensure there is a temp directory

		. (Join-Path -Path $PSScriptRoot -ChildPath "..\Helpers\New-TempDir.ps1")
		$targetTempDir = New-TempDir $TargetSession

		# Download installer

		$downloadUrlSegments = ([Uri]$jreDownloadUrl).Segments
		$installerFileName = $downloadUrlSegments[$downloadUrlSegments.Count - 1]

		$targetInstallerLocation = Join-Path -Path $targetTempDir -ChildPath $installerFileName

		if (!(Invoke-Command -Session $TargetSession -ScriptBlock { Test-Path -Path $using:targetInstallerLocation })) {
		
			echo "Downloading Java installer..."

			Invoke-Command -Session $TargetSession -ScriptBlock {
			
				$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
				$cookie = [System.Net.Cookie]::new("oraclelicense", "accept-securebackup-cookie", "/", ".oracle.com")
				$webSession.Cookies.Add($cookie);

				Invoke-WebRequest -Uri $using:jreDownloadUrl -WebSession $webSession -OutFile $using:targetInstallerLocation
			}
		}

		# Run installer

		echo "Running Java installer..."
		
		$logFileName = "java-installation-logfile.txt"
		$targetLogFileLocation = Join-Path -Path $targetTempDir -ChildPath $logFileName
		
		Invoke-Command -Session $TargetSession -ScriptBlock {
			Start-Process -FilePath $using:targetInstallerLocation -ArgumentList "/s","/L","$using:targetLogFileLocation" -Wait
			Update-SessionEnvironment
		}
	}
}