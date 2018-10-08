# JenkinsAutomation

PowerShell scripts for setting up Jenkins build agents

# About

This is the automation we use when setting up new build agents for our Unity projects. We run our build agents in Google Cloud Platform.
New build nodes are configured with Plastic SCM, Unity 3D and steamcmd.exe.

A new machine can be set up from scratch in approximately 30 minutes. If you generate a disk snapshot when all installation is complete, new GCE instances can be spun up and activated in a couple of minutes each.

# Operation

## Before you start

- Ensure you have a spare seat for a Unity Plus/Pro/Enterprise license
- Ensure you have a Google Cloud Platform account, with billing configured
- Ensure you have installed & configured [Cloud Tools for Powershell](https://cloud.google.com/tools/powershell/docs/quickstart) on your computer
- Ensure you have [Java 8](https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed on your computer
- Ensure you have a Jenkins master running
- Ensure you have configured [an API Token](https://jenkins.io/blog/2018/07/02/new-api-token-system/) for your user on the Jenkins master

