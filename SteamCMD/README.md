# SteamCMD installation scripts

[SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) is the command-line version of the Steam client.
Its primary use on a build system is to package game builds and upload them to Steam.

`steamcmd.exe` will be installed to a separate location on the machine and added to the system PATH. There are two reasons for doing this, instead of including steamcmd.exe in the source repository:
1. `steamcmd.exe` has its own auto-updater mechanism. If `steamcmd.exe` is included in the source repository, the auto-updater will conflict with the versioning done by the source control system.
2- `steamcmd.exe` [needs to have Steam Guard active](https://partner.steamgames.com/doc/sdk/uploading#Building_Depots) to be allowed to upload builds to Steam. Steam Guard, in turn, requires a manual activation step on each machine. This is also in conflict with how the source control system operates.

We should build an `Activate-SteamCMD` command.

# Script index

[Install-SteamCMD](Install-SteamCMD.ps1) Installs `steamcmd.exe` onto the machine and adds it to the system PATH
