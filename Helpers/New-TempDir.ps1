
$targetTempDir = "c:\temp"

function New-TempDir
{
	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Session
	)

	Invoke-Command -Session $Session -ScriptBlock {
	
		# Create temp directory if it doesn't already exist
	
		md -Force -Path $using:targetTempDir | Out-Null
	}
	
	return $targetTempDir
}