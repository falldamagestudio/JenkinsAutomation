
function Install-NetFramework-3_5 {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession
	)

	# Skip if .NET framework 3.5 is already installed
	
	if (!(Invoke-Command -Session $TargetSession -ScriptBlock { (Get-WindowsFeature Net-Framework-Core).Installed })) {
	
		# Install .NET Framework 3.5

		echo "Installing .NET Framework 3.5..."

		Invoke-Command -Session $TargetSession -ScriptBlock { Install-WindowsFeature Net-Framework-Core | Out-Null }
	}
}
