
# See https://stackoverflow.com/questions/44751960/install-jenkins-slave-as-a-windows-service-in-command-line for reference

function Install-JenkinsSlave {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterUrl
	)

	# Ensure Jenkins folder exists

	$installDir = "c:\Jenkins"

	Invoke-Command -Session $TargetSession -ScriptBlock { md -Force $using:installDir | Out-Null }

	# Copy over Non-Sucky Service Manager

	$nssmFileName = "nssm.exe"
	
	$sourceNssmLocation = Join-Path -Path $PSScriptRoot -ChildPath $nssmFileName
	
	$targetNssmLocation = Join-Path -Path $installDir -ChildPath $nssmFileName
	
	if (!(Invoke-Command -Session $TargetSession -ScriptBlock { Test-Path($using:targetNssmLocation) })) {
		echo "Copying NSSM executable to remote system..."
		Copy-Item -Path $sourceNssmLocation -ToSession $TargetSession -Destination $targetNssmLocation
	}

	# Download slave .jar

	$slaveJarDownloadRelativeLocation = "jnlpJars/remoting.jar"

	$slaveJarFileName = "slave.jar"
	
	$slaveJarDownloadUrl = [System.Uri]::new([System.Uri]$JenkinsMasterUrl, $slaveJarDownloadRelativeLocation)

	$slaveJarLocation = Join-Path -Path $installDir -ChildPath $slaveJarFileName
	
	if (!(Invoke-Command -Session $TargetSession -ScriptBlock { Test-Path($using:slaveJarLocation) })) {
		echo "Downloading slave .jar from Jenkins master..."
		Invoke-Command -Session $TargetSession -ScriptBlock { Invoke-WebRequest -Uri $using:slaveJarDownloadUrl -OutFile $using:slaveJarLocation }
	}
}
