
#function Send-EnvironmentChangeMessage {
#	# Broadcast the Environment variable changes, so that other processes pick changes to Environment variables without having to reboot or logoff/logon. 
#	if (-not ('Microsoft.PowerShell.Commands.PowerShellGet.Win32.NativeMethods' -as [type])) {
#		Add-Type -Namespace Microsoft.PowerShell.Commands.PowerShellGet.Win32 `
#				-Name NativeMethods `
#				-MemberDefinition @'
#					[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
#					public static extern IntPtr SendMessageTimeout(
#						IntPtr hWnd,
#						uint Msg,
#						UIntPtr wParam,
#						string lParam,
#						uint fuFlags,
#						uint uTimeout,
#						out UIntPtr lpdwResult);
#'@
#	}
#
#	$HWND_BROADCAST = [System.IntPtr]0xffff;
#	$WM_SETTINGCHANGE = 0x1a;
#	$result = [System.UIntPtr]::zero
#
#	# https://msdn.microsoft.com/en-us/library/windows/desktop/ms644952(v=vs.85).aspx
#	$returnValue = [Microsoft.PowerShell.Commands.PowerShellGet.Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, 
#																										$WM_SETTINGCHANGE,
#																										[System.UIntPtr]::Zero, 
#																										'Environment',
#																										2, 
#																										5000,
#																										[ref]$result);
#	# A non-zero result from SendMessageTimeout indicates success.
#	if($returnValue) {
#		Write-Host 'Successfully broadcasted the Environment variable changes.'
#	} else {
#		Write-Host 'Error in broadcasting the Environment variable changes.'
#	}
#}

function Install-Plastic {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$Version
	)
	
	. (Join-Path -Path $PSScriptRoot -ChildPath Get-PlasticInstallParameters.ps1)
	$installerParameters = Get-PlasticInstallParameters($Version)

	$installerDownloadUrl = $installerParameters.InstallerDownloadUrl
	$installerFileName = $installerParameters.InstallerFileName
	$applicationRegistryKey = $installerParameters.ApplicationRegistryKey

	$installerLogFileName = "plastic_install_log.txt"

	# Skip if the exact same version of the application is already installed
	
	if (!(Invoke-Command -Session $targetSession -ScriptBlock { Test-Path -Path $using:applicationRegistryKey })) {
	
		# Ensure there is a temp directory

		. (Join-Path -Path $PSScriptRoot -ChildPath "..\Helpers\New-TempDir.ps1")
		$targetTempDir = New-TempDir $TargetSession

		# Download installer

		$targetDownloadLocation = Join-Path -Path $targetTempDir -ChildPath $installerFileName

		if (!(Invoke-Command -Session $targetSession -ScriptBlock { Test-Path -Path $using:targetDownloadLocation })) {
			echo "Downloading Plastic..."
			Invoke-Command -Session $targetSession -ScriptBlock { Invoke-WebRequest -Uri $using:installerDownloadUrl -OutFile $using:targetDownloadLocation }
		}

		# Run installer

		$installerLogLocation = Join-Path -Path $targetTempDir -ChildPath $installerLogFileName
		
		echo "Installing Plastic..."

		Invoke-Command -Session $TargetSession -ScriptBlock { Start-Process -FilePath $using:targetDownloadLocation -ArgumentList "--mode","unattended","--debugtrace",$using:installerLogLocation -Wait }

		# Add environment variables (these are not added when running installation in unattended mode)

		$plasticInstallDir = "C:\Program Files\PlasticSCM5"
		$plasticClientInstallDir = Join-Path -Path $plasticInstallDir -ChildPath "Client"
		$plasticServerInstallDir = Join-Path -Path $plasticInstallDir -ChildPath "Server"

		. .\Add-Path.ps1
		Add-Path -TargetSession $targetSession -Path $plasticClientInstallDir
		Add-Path -TargetSession $targetSession -Path $plasticServerInstallDir
	}

}
