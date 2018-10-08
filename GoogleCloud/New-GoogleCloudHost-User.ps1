
function New-GoogleCloudHost-User {

	param (
		[Parameter(Mandatory=$true)][string]$HostName,
		[Parameter(Mandatory=$true)][string]$UserName
	)

	echo "Creating Windows user account & resetting password..."
	
	gcloud compute reset-windows-password $HostName "--user=$UserName"
}
