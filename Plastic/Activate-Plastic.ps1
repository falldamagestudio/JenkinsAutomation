
function Activate-Plastic {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$PlasticCredential,
		[Parameter(Mandatory=$true)][string]$PlasticServer,
		[Parameter(Mandatory=$true)][string]$PlasticCloudContentEncryptionPassword
	)

	. (Join-Path -Path $PSScriptRoot -ChildPath "..\Helpers\New-TempDir.ps1")
	$targetTempDir = New-TempDir $TargetSession
	
	echo "Installing Plastic configuration files..."
	
	$targetLocalAppDataLocation = Invoke-Command -Session $TargetSession -ScriptBlock { $env:LOCALAPPDATA }
	$targetLocalPlastic4FolderName = "plastic4"
	$targetLocalPlastic4FolderLocation = Join-Path -Path $targetLocalAppDataLocation -ChildPath $targetLocalPlastic4FolderName

	$plasticUserName = ($PlasticCredential).UserName
	$plasticPassword = ($PlasticCredential).GetNetworkCredential().Password

	$configSourceFolder = "PlasticCloudClientConfig"

	# Encrypt passwords
	
	# TODO: find a way to run the 'cm crypt' command on the target machine, without requiring the cm client to have been correctly configured beforehand
	# During the most recent tests, 'cm crypt <password>' would always emit an error message about a missing client.conf when it was run remotely via this script
	
	$stdoutTempFileName = "cm.output.temp.txt"
	$stdoutTempFileLocation = (Join-Path -Path $PSScriptRoot -ChildPath $stdoutTempFileName)
	$prefixString = "ENCRYPTED: |SoC|"

	Start-Process -FilePath "cm" -ArgumentList "crypt","""$plasticPassword""" -NoNewWindow -RedirectStandardOutput $stdoutTempFileLocation -Wait
	$encryptedPassword = (Get-Content $stdoutTempFileLocation).Replace($prefixString, "")
	Remove-Item $stdoutTempFileLocation
	
	Start-Process -FilePath "cm" -ArgumentList "crypt","""$PlasticCloudContentEncryptionPassword""" -NoNewWindow -RedirectStandardOutput $stdoutTempFileLocation -Wait
	$encryptedContentPassword = (Get-Content $stdoutTempFileLocation).Replace($prefixString, "")
	Remove-Item $stdoutTempFileLocation

	$plasticCredentialString = "::0:{0}:{1}:" -f ($plasticUserName, $encryptedPassword)

	# Create config file folder under %APPDATA%\Local
	
	Invoke-Command -Session $targetSession -ScriptBlock { mkdir -Path $using:targetLocalPlastic4FolderLocation -Force | Out-Null }

	# Install client.conf
	
	$clientConfFileName = "client.conf"

	$clientConfTempFileName = "client.temp.conf"
	$clientConfTempLocation = (Join-Path -Path $PSScriptRoot -ChildPath $clientConfTempFileName)
	
	$clientConfXml = [xml] (Get-Content ([IO.Path]::Combine($PSScriptRoot, $configSourceFolder, $clientConfFileName)))
	$clientConfXml.ClientConfigData.WorkspaceServer = $PlasticServer
	$clientConfXml.ClientConfigData.SecurityConfig = $plasticCredentialString
	
	$clientConfXml.PreserveWhitespace = $false
	$clientConfXml.Save([System.IO.Path]::GetFullPath($clientConfTempLocation))

	Copy-Item -Path $clientConfTempLocation -ToSession $TargetSession -Destination (Join-Path -Path $targetLocalPlastic4FolderLocation -ChildPath $clientConfFileName) -Force
	
	Remove-Item $clientConfTempLocation

	# Install profiles.conf
	
	$profilesConfFileName = "profiles.conf"

	$profilesConfTempFileName = "profiles.temp.conf"
	$profilesConfTempLocation = (Join-Path -Path $PSScriptRoot -ChildPath $profilesConfTempFileName)
	
	$profilesConfXml = [xml] (Get-Content ([IO.Path]::Combine($PSScriptRoot, $configSourceFolder, $profilesConfFileName)))
	$profilesConfXml.ServerProfileData.Profiles.ServerProfile.Name = $PlasticServer
	$profilesConfXml.ServerProfileData.Profiles.ServerProfile.Server = $PlasticServer
	$profilesConfXml.ServerProfileData.Profiles.ServerProfile.SecurityConfig = $plasticCredentialString
	
	$profilesConfXml.PreserveWhitespace = $false
	$profilesConfXml.Save([System.IO.Path]::GetFullPath($profilesConfTempLocation))

	Copy-Item -Path $profilesConfTempLocation -ToSession $TargetSession -Destination (Join-Path -Path $targetLocalPlastic4FolderLocation -ChildPath $profilesConfFileName) -Force

	Remove-Item $profilesConfTempLocation

	# Install <servername>.key

	$keyFileName = "{0}.key" -f $PlasticServer

	$targetKeyFileLocation = Join-Path -Path $targetLocalPlastic4FolderLocation -ChildPath $keyFileName
	
	Invoke-Command -Session $targetSession -ScriptBlock { Set-Content -Path $using:targetKeyFileLocation -Value ("AES128 |SoC|{0}`n" -f ($using:encryptedContentPassword)) -Encoding ASCII }

	# Install cryptedservers.conf

	$cryptedServersConfFileName = "cryptedservers.conf"
	
	$cryptedServersConfLocation = Join-Path -Path $targetLocalPlastic4FolderLocation -ChildPath $cryptedServersConfFileName
	
	Invoke-Command -Session $targetSession -ScriptBlock { Set-Content -Path $using:cryptedServersConfLocation -Value ("{0} {1}`n" -f ($using:PlasticServer, $using:keyFileName)) -Encoding ASCII }

}
