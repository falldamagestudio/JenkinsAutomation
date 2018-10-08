
function Install-HelperPackages {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession
	)

	Invoke-Command -Session $TargetSession -ScriptBlock {

		# Install NuGet as a package provider source for OneGet

		Install-PackageProvider -Name NuGet -Force | Out-Null
		
		# Install utils package that includes Update-SessionEnvironment
		
		Install-Module -Name SimpleSoft.Utils -Force
	}
}