
function Uninstall-JenkinsSlave {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterUrl,
		[Parameter(Mandatory=$true)][string]$NodeName,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterUser,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterAPIToken
	)

	# Remove node from master

	echo "Removing Jenkins node from master..."

	$jenkinsCliFileName = "jenkins-cli.jar"
	
	$jenkinsCliLocation = Join-Path -Path $PSScriptRoot -ChildPath $jenkinsCliFileName
	
	Start-Process -FilePath "java" -ArgumentList "-jar",$jenkinsCliLocation,"-s",$JenkinsMasterUrl,"-auth","$($JenkinsMasterUser):$($JenkinsMasterAPIToken)","delete-node",$NodeName -NoNewWindow -Wait
	
	# ------------------------------------------------------------------

	$installDir = "c:\Jenkins"

	# Remove Jenkins Agent as a Windows service
	
	echo "Unregistering Jenkins Agent service..."
	
	$jenkinsServiceName = "Jenkins Agent"
	
	$nssmFileName = "nssm.exe"
	
	$targetNssmLocation = Join-Path -Path $installDir -ChildPath $nssmFileName

	Invoke-Command -Session $TargetSession -ScriptBlock {

		# Stop service
		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "stop","""$using:jenkinsServiceName""" -Wait

		# Uninstall service
		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "remove","""$using:jenkinsServiceName""","confirm" -Wait
	}

}
