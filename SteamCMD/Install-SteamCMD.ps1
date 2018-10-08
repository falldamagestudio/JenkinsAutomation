
function Install-SteamCMD {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession
	)

	$installDir = "C:\ProgramsWithoutInstallers\SteamCMD"
	$targetExeName = "steamcmd.exe"
	$targetExeLocation = Join-Path -Path $installDir -ChildPath $targetExeName
	
	# Skip installation if SteamCMD is already present on the machine
	
	if (!(Invoke-Command -Session $targetSession -ScriptBlock { Test-Path -Path $using:targetExeLocation })) {

		echo "Installing SteamCMD..."

		# Ensure there is a temp directory

		. (Join-Path -Path $PSScriptRoot -ChildPath "..\Helpers\New-TempDir.ps1")
		$targetTempDir = New-TempDir $TargetSession

		# Download installation zip
	
		$archiveDownloadUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"				# Download URL taken from https://developer.valvesoftware.com/wiki/SteamCMD
		$archiveName = "steamcmd.zip"
		$archiveDownloadLocation = Join-Path -Path $targetTempDir -ChildPath $archiveName

		Invoke-Command -Session $TargetSession -ScriptBlock { Invoke-WebRequest -Uri $using:archiveDownloadUrl -OutFile $using:archiveDownloadLocation }
		
		# Unpack SteamCMD

		Invoke-Command -Session $TargetSession -ScriptBlock { Expand-Archive -Path $using:archiveDownloadLocation -DestinationPath $using:installDir -Force }
		if (!(Invoke-Command -Session $targetSession -ScriptBlock { Test-Path $using:targetExeLocation })) {
			Write-Error -Message "SteamCMD archive did not contain any steamcmd.exe executable"
		}

		# Add installation folder to Path

		. .\Add-Path.ps1
		Add-Path -TargetSession $TargetSession -Path $installDir
		
		# Run SteamCMD once, to force updating to latest version

		Invoke-Command -Session $TargetSession -ScriptBlock { Start-Process -FilePath $using:targetExeLocation -ArgumentList "+quit" -Wait }
	}
}
