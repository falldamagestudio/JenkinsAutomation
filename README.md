# Jenkins Automation

PowerShell scripts for setting up Jenkins build agents for Unity projects

# About

This is the automation we use when setting up new build agents for our Unity projects. We run our build agents in Google Cloud Platform.
New build nodes are configured with Plastic SCM, Unity 3D and steamcmd.exe.

A new machine can be set up from scratch in approximately 30 minutes. If you take a disk snapshot when installation is complete, new cloud-based instances can be spun up and activated in a couple of minutes each.

We use Declarative Pipeline jobs to control our build process. Freestyle jobs will not find the Unity installation(s).

# Usage

The [GoogleCloud](GoogleCloud) scripts deal with the machine which will run the Jenkins agent. They create/destroy a Google Compute Engine instance,
and establish a PowerShell session to the instance. If you want to use a machine from elsewhere (AWS, Azure, a desktop machine in your office, ...) then you can do so.
Just make sure that the machine runs Windows Server 2016 or an equivalent non-server version of Windows, and that you can connect to the machine via PowerShell / Remote Desktop Connection.

The remaining scripts perform installation/activation of various bits of software onto the machine.
All these scripts take a `-TargetSession` parameter -- a PowerShell remote session. All configuration is done via this PowerShell session.
Most scripts will fetch installers from the Internet directly to the target machine, and then invoke those installers.

Many scripts come in `Install-` and `Activate-`-flavors. The `Install-` steps download installers and execute them, but do not leave any sensitive or instance-specific information on the machine.
When all `Install-`-scripts have been run, you can take a snapshot of the machine's hard drive.
This snapshot is suitable as a base image if you are going to spin up many identical Jenkins agent machines.
You will need to run the `Activate-` steps separately on each machine afterward.

## Before you start

- Ensure you have [a spare seat for a Unity Plus/Pro/Enterprise license](https://github.com/falldamagestudio/JenkinsAutomation/tree/master/Unity#license-management)
- Ensure you have a Google Cloud Platform account, with billing configured
- Ensure you have installed & configured [Cloud Tools for Powershell](https://cloud.google.com/tools/powershell/docs/quickstart) on your computer
- Ensure you have [Java 8](https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed on your computer
- Ensure you have a Jenkins master running
- Ensure you have configured [an API Token](https://jenkins.io/blog/2018/07/02/new-api-token-system/) for your user on the Jenkins master

## Create a new machine

Open PowerShell on your computer.
```
$hostName = "<Name for your new machine>"

. .\GoogleCloud\New-GoogleCloudHost.ps1
New-GoogleCloudHost -Name $hostName -MemorySizeMB 9216 -DiskSizeGB 200
```
Wait approximately 1-2 minutes.
```
. .\GoogleCloud\New-GoogleCloudHost-User.ps1
New-GoogleCloudHost-User -HostName $hostName -UserName "Jenkins"
	< answer Yes to the question >
	< if password reset didn't succeed, wait a minute and retry >
	< save IP, username and password >
```

## Install software onto the machine

Ensure that it is possible to reach the target machine via Windows Remote Management (WinRM). This is run on TCP port 5986. For Google Cloud, [you may need to add a new firewall rule](https://cloud.google.com/compute/docs/instances/connecting-to-instance).

Open PowerShell on your computer.
```
$hostName = "<Name for your machine>"

$jenkinsMasterUrl = "<URL to the Jenkins master Web UI>"

$unityVersion = "<desired Unity version>"                       # for example "2018.2.5f1"
$unityComponents = "<desired components for Unity version>"     # for example "Windows64-editor"

$machineCredential = Get-Credential
	< type in username and password for the machine >

----------------------------------

$targetIp = (Get-GceInstance $hostName).NetworkInterfaces[0].AccessConfigs[0].NatIP

. .\Helpers\Enable-Tls12.ps1
Enable-Tls12

. .\GoogleCloud\New-PSSession-GoogleCloudHost.ps1
$targetSession = New-PSSession-GoogleCloudHost -TargetIp $targetIp -Credential $machineCredential

. .\Helpers\Install-HelperPackages.ps1
Install-HelperPackages -TargetSession $targetSession

. .\Java\Install-Java.ps1
Install-Java -TargetSession $targetSession

. .\NetFramework-3_5\Install-NetFramework-3_5.ps1
Install-NetFramework-3_5 -TargetSession $targetSession

. .\Plastic\Install-Plastic.ps1
Install-Plastic -TargetSession $targetSession -Version "7.0.16.2562"

. .\SteamCMD\Install-SteamCMD.ps1
Install-SteamCMD -TargetSession $targetSession

. .\Unity\Install-Unity.ps1
Install-Unity -TargetSession $targetSession -Version $unityVersion -Components $unityComponents

. .\JenkinsAgent\Install-JenkinsSlave.ps1 
Install-JenkinsSlave -TargetSession $targetSession -JenkinsMasterUrl $jenkinsMasterUrl
```

This is a good time to create a disk image of the machine in case you want to start up multiple machines with the same configuration.

## Activate software on the machine

Open PowerShell on your computer.
```
$hostName = "<Name for your machine>"

$jenkinsMasterUrl = "<URL to the Jenkins master Web UI>"
$jenkinsMasterUser = "<Username which you use when logging in to the Jenkins master Web UI>"
$jenkinsMasterAPIToken = "<An API token which is associated with your Jenkins user>"

$machineCredential = Get-Credential
	< type in username and password for the machine >

$plasticCredential = Get-Credential
	< type in username and password for the Plastic user account >

$plasticServer = "<server:port for your Plastic server, or your Plastic Cloud organization"   # for example: "MyCompany@cloud"
$plasticContentEncryptionPassword = "<the cloud content encryption password for your Plastic server / Plastic Cloud organization>"

$unityCredential = Get-Credential
	< type in username and password for the Unity ID account >

$unitySerial = "<Serial number for the Unity ID account>"   # on the form: "SB-XXXX-XXXX-XXXX-XXXX-XXXX"
# You can find the serial number at https://id.unity.com, under "My Seats"

----------------------------------

$targetIp = (Get-GceInstance $hostName).NetworkInterfaces[0].AccessConfigs[0].NatIP

. .\Helpers\Enable-Tls12.ps1
Enable-Tls12

. .\GoogleCloud\New-PSSession-GoogleCloudHost.ps1
$targetSession = New-PSSession-GoogleCloudHost -TargetIp $targetIp -Credential $machineCredential

. .\Plastic\Activate-Plastic.ps1
Activate-Plastic -TargetSession $targetSession -PlasticCredential $plasticCredential -PlasticServer $plasticServer -PlasticCloudContentEncryptionPassword $plasticContentEncryptionPassword

. .\Unity\Activate-Unity.ps1
Activate-Unity -TargetSession $targetSession -UnityCredential $unityCredential -Serial $unitySerial

. .\JenkinsAgent\Activate-JenkinsSlave.ps1 
Activate-JenkinsSlave -TargetSession $targetSession -JenkinsMasterUrl $jenkinsMasterUrl -NodeName $hostName -Credential $machineCredential -JenkinsMasterUser $jenkinsMasterUser -JenkinsMasterAPIToken $jenkinsMasterAPIToken

TODO: implement scripted activation of Steam Guard -- for now, do it manually:
log onto the machine and perform "steamcmd.exe +login <username> <password>". This will trigger a Steam Guard check.
Fetch the Steam Guard code from the appropriate place (Steam Authenticator or email) and enter it.
```

The Jenkins agent will now be registered with the Jenkins master and ready to take build jobs. It will have a single label, equivalent to `$hostName`.

## Deactivate software on the machine

This will return any active licenses on the machine and remove the build agent from the master.

Open PowerShell on your computer.
```
$hostName = "<Name for your machine>"

$jenkinsMasterUrl = "<URL to the Jenkins master Web UI>"
$jenkinsMasterUser = "<Username which you use when logging in to the Jenkins master Web UI>"
$jenkinsMasterAPIToken = "<An API token which is associated with your Jenkins user>"

----------------------------------

$targetIp = (Get-GceInstance $hostName).NetworkInterfaces[0].AccessConfigs[0].NatIP

. .\Helpers\Enable-Tls12.ps1
Enable-Tls12

. .\GoogleCloud\New-PSSession-GoogleCloudHost.ps1
$targetSession = New-PSSession-GoogleCloudHost -TargetIp $targetIp -Credential $machineCredential

. .\JenkinsAgent\Uninstall-JenkinsSlave.ps1
Uninstall-JenkinsSlave -TargetSession $targetSession -JenkinsMasterUrl $jenkinsMasterUrl -NodeName $hostName -JenkinsMasterUser $jenkinsMasterUser -JenkinsMasterAPIToken $jenkinsMasterAPIToken

TODO: implement deactivation of Unity license -- for the time being, you will have to visit https://id.unity.com and manually remove the activation under "My Seats".
```

The Jenkins master no longer knows about the build agent.

## Destroy machine

Open PowerShell on your computer.
```
$hostName = "<Name for your machine>"

. .\GoogleCloud\Remove-GoogleCloudHost.ps1
Remove-GoogleCloudHost -Name $hostName
```
