
function Activate-JenkinsSlave {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterUrl,
		[Parameter(Mandatory=$true)][string]$NodeName,
		[Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credential,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterUser,
		[Parameter(Mandatory=$true)][string]$JenkinsMasterAPIToken
	)

	# Add node to master

	echo "Adding Jenkins node to master..."

	$jenkinsSlaveConfigLocation = "jenkins-slave-config.xml"

	$jenkinsSlaveConfig = [xml] (Get-Content (Join-Path -Path $PSScriptRoot -ChildPath $jenkinsSlaveConfigLocation))
	$jenkinsSlaveConfig.slave.description = $NodeName
	$jenkinsSlaveConfig.slave.label = $NodeName

	$jenkinsCliFileName = "jenkins-cli.jar"
	$jenkinsCliLocation = (Join-Path -Path $PSScriptRoot -ChildPath $jenkinsCliFileName)
	
	$jenkinsSlaveTempConfigLocation = (Join-Path -Path $PSScriptRoot -ChildPath "jenkins-slave-config.temp.xml")

	$jenkinsSlaveConfig.PreserveWhitespace = $false
	$jenkinsSlaveConfig.Save([System.IO.Path]::GetFullPath($jenkinsSlaveTempConfigLocation))

	Start-Process -FilePath "java" -ArgumentList "-jar",$jenkinsCliLocation,"-s",$JenkinsMasterUrl,"-auth","$($JenkinsMasterUser):$($JenkinsMasterAPIToken)","create-node",$NodeName -RedirectStandardInput $jenkinsSlaveTempConfigLocation -NoNewWindow -Wait

	Remove-Item $jenkinsSlaveTempConfigLocation
	
	# Retrieve agent-specific secret

	$jenkinsGetNodeSecretInputTempLocation = (Join-Path -Path $PSScriptRoot -ChildPath "jenkins-slave-get-secret.input.temp.groovy")
	echo "println jenkins.model.Jenkins.instance.nodesObject.getNode(""$($NodeName)"")?.computer?.jnlpMac" | Out-File $jenkinsGetNodeSecretInputTempLocation -Encoding ASCII
	
	$jenkinsGetNodeSecretOutputTempLocation = (Join-Path -Path $PSScriptRoot -ChildPath "jenkins-slave-get-secret.output.temp.txt")
	Start-Process -FilePath "java" -ArgumentList "-jar",$jenkinsCliLocation,"-s",$JenkinsMasterUrl,"-auth","$($JenkinsMasterUser):$($JenkinsMasterAPIToken)","groovy","=" -RedirectStandardInput $jenkinsGetNodeSecretInputTempLocation -RedirectStandardOutput $jenkinsGetNodeSecretOutputTempLocation -NoNewWindow -Wait

	$agentSecret = Get-Content $jenkinsGetNodeSecretOutputTempLocation

	Remove-Item $jenkinsGetNodeSecretInputTempLocation
	Remove-Item $jenkinsGetNodeSecretOutputTempLocation
	
	# ------------------------------------------------------------------

	$installDir = "c:\Jenkins"

	# Setup slave .jar to run a service, automatically starting at machine startup

	echo "Installing Windows service for slave .jar..."
	
	$jenkinsServiceName = "Jenkins Agent"
	
	$nssmFileName = "nssm.exe"
	
	$targetNssmLocation = Join-Path -Path $installDir -ChildPath $nssmFileName

	$slaveJarFileName = "slave.jar"

	$slaveJarLocation = Join-Path -Path $installDir -ChildPath $slaveJarFileName
	
	Invoke-Command -Session $TargetSession -ScriptBlock {
	
		$env:JENKINS_JVM_LAUNCH_ARGS = "-Xmx768m"
		[Environment]::SetEnvironmentVariable("JENKINS_JVM_LAUNCH_ARGS", $env:JENKINS_JVM_LAUNCH_ARGS, [EnvironmentVariableTarget]::Machine)
	
		$env:JENKINS_MASTER_JNLP_URL = [System.Uri]::new([System.Uri]$using:JenkinsMasterUrl, "/computer/{0}/slave-agent.jnlp" -f $using:NodeName)
		[Environment]::SetEnvironmentVariable("JENKINS_MASTER_JNLP_URL", $env:JENKINS_MASTER_JNLP_URL, [EnvironmentVariableTarget]::Machine)

		$env:JENKINS_SLAVE_SECRET = $using:agentSecret
		[Environment]::SetEnvironmentVariable("JENKINS_SLAVE_SECRET", $env:JENKINS_SLAVE_SECRET, [EnvironmentVariableTarget]::Machine)

		$env:JENKINS_SLAVE_WORK_DIR = $using:installDir
		[Environment]::SetEnvironmentVariable("JENKINS_SLAVE_WORK_DIR", $env:JENKINS_SLAVE_WORK_DIR, [EnvironmentVariableTarget]::Machine)
		
		# Install service
		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "install","""$using:jenkinsServiceName""","java.exe","%JENKINS_JVM_LAUNCH_ARGS%","-jar","""$using:slaveJarLocation""","-jnlpUrl","%JENKINS_MASTER_JNLP_URL%","-secret","%JENKINS_SLAVE_SECRET%","-workDir","%JENKINS_SLAVE_WORK_DIR%" -Wait
		
		# Ensure service runs under appropriate user
		$userNameWithDomain = ".\{0}" -f ($using:Credential).UserName
		$password = ($using:Credential).GetNetworkCredential().Password
		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "set","""$using:jenkinsServiceName""","ObjectName","""$userNameWithDomain""","""$password""" -Wait
		# Ensure service starts up at application start time
		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "set","""$using:jenkinsServiceName""","Start","SERVICE_AUTO_START" -Wait

		Start-Process -FilePath $using:targetNssmLocation -ArgumentList "start","""$using:jenkinsServiceName""" -Wait
	}

}
