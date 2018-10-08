# Google Cloud scripts for managing slave machines

These scripts can be used to rent machines from Google Cloud

A machine is managed as a triplet of resources: A public IP address, a persistent disk, and a compute instance (VM).

Unity needs 8-9GB RAM to build our current game. Most of the build process runs single-threaded; therefore we give it only 2 CPUs. The disk is of SSD type; we haven't measured but hopefully it helps processing times.

## Specific scripts

[New-GoogleCloudHost](New-GoogleCloudHost.ps1) rents and configures a new machine.

[New-GoogleCloudHost-User](New-GoogleCloudHost-User.ps1) creates a Windows user on the new machine. The command will fail if the machine has just been created; normally, waiting 2 minutes is sufficient.

[New-PSSession-GoogleCloudHost](New-PSSession-GoogleCloudHost.ps1) creates a PowerShell remote session to the machine. Some [specific switches are required](https://cloud.google.com/compute/docs/instances/connecting-to-instance#windows_cli) when creating a remote session to a machine in GCE.

[Remove-GoogleCloudHost](Remove-GoogleCloudHost.ps1) destroys a machine.
