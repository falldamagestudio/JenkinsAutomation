# Unity installation scripts

These scripts automate installation, and activation of the Unity Editor.

## Downloading Editor builds

The Unity Editor is distributed in three ways:

- The [Unity Hub](https://docs.unity3d.com/Manual/GettingStartedUnityHub.html) is a GUI that allows for downloading of various versions of the Unity Editor. However, it has no headless mode, and it only offers the latest patch version of each minor version - so it is not suitable for downloading an exact version.
- Unity makes Download Assistant installers available. These are small GUI installer front-ends in front of the component installers. The Download Assistants do not support headless installation.
- Unity makes offline installers available for the Editor and the various components. There is no discovery mechanism for these, so we have begun constructing [a manually-maintained index of download URLs](https://falldamagestudio.github.io/UnityDownloadURLs/).

Do ask your Unity representative about future plans for unattended installation of a specific version of the Unity Editor onto a machine!

## License management

Before the Unity Editor can be used on a machine, it needs to be activated. Activation of a headless instance requires a serial to be specified. Therefore, only Unity Plus/Pro/Enterprise accounts can be used with headless activation.

You can install multiple Unity Editor versions concurrently on the same machine. A single Unity activation is valid for all Unity Editor installations on the same machine.

Unity offers no "build machine" specific licenses -- their entire licensing system is designed for physical users. You have two options:
- Each Unity Plus/Pro account has two seats. Some of your team members probably only use one of those two seats. You can re-purpose the second seat for build machines. This requires your team members to share their Unity ID passwords with IT staff. It also means that if any of those team members choose to release their activations via [id.unity.com](https://id.unity.com), the corresponding build machine will stop working.
- Purchase one extra Unity Plus/Pro license for each two build machines.

Do ask your Unity representative about future plans for build machine licenses!

## Script index

[Install-Unity](Install-Unity.ps1) downloads and installs specified versions of the Unity Editor plus (optional) additional components.

[Activate-Unity](Activate-Unity.ps1) activates a Unity seat using the specified Unity Editor installation.
