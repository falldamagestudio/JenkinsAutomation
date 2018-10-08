
function New-GoogleCloudHost {

	param (
		[Parameter(Mandatory=$true)][string]$Name,
		[Parameter(Mandatory=$true)][int]$MemorySizeMB,
		[Parameter(Mandatory=$true)][int]$DiskSizeGB
	)

	
	try {
	
		echo "Allocating public IP address..."

		$address = Add-GceAddress $Name
		
		echo "Creating boot disk..."

		$bootDiskImage = Get-GceImage "windows-cloud" -Family "windows-2016"

		$bootDisk = New-GceDisk $Name -DiskType "pd-ssd" -Image $bootDiskImage -SizeGb $DiskSizeGB
		
		echo "Creating new Compute instance..."
		
		$instance = Add-GceInstance $Name -Address ($address).AddressValue -BootDisk $bootDisk -CustomCpu 2 -CustomMemory $MemorySizeMB

	} catch {
	
		echo "Something went wrong; cleaning up after $($Name)..."
	
		if ($instance) {
			Stop-GceInstance $instance
			Remove-GceInstance $instance
		}
		
		if ($bootDisk) {
			Remove-GceDisk $bootDisk
		}
		
		if ($address) {
			Remove-GceAddress $Name
		}
		
		throw
	}
}
