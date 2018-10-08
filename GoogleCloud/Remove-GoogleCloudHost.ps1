
function Remove-GoogleCloudHost {

	param (
		[Parameter(Mandatory=$true)][string]$Name
	)

	echo "Deleting GCE instance, disk, and public IP address..."
	
	try { 
		Stop-GceInstance $Name
		Remove-GceInstance $Name
	} catch { }

	try {
		Remove-GceDisk $Name
	} catch { }
	
	try {
		Remove-GceAddress $Name
	} catch { }
}