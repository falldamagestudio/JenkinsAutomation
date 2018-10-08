
function Add-Path {

	param (
		[Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$TargetSession,
		[Parameter(Mandatory=$true)][string]$Path
	)

	Invoke-Command -Session $targetSession -ScriptBlock {
	
		$envPaths = $env:Path -split ";"

		if (!($envPaths -contains $using:Path)) {
			$delimiter = if ($env:Path.EndsWith(';')) { "" } else { ";" }
			$env:Path = ("{0}{1}{2}" -f $env:Path,$delimiter,$using:Path)
			[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)
		}
	}
}