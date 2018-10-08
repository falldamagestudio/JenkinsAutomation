# Jenkins agent installation scripts

These scripts automate the process of installing the Jenkins agent software, Jenkins master configuration, and system service setup.

The agent code is [available on the Jenkins master at http://yourserver:port/jnlpJars/agent.jar](https://wiki.jenkins.io/display/JENKINS/Distributed+builds) (and also under the old name, `slave.jar`).

The agent code is installed as a Windows service. This allows automatic startup of the agent code whenever the machine starts / restarts.

[Non-Sucky Service Manager](https://nssm.cc/) is used to launch/monitor the Java process. NSSM makes service registration/deregistration straightforward.

## Script index

[Install-JenkinsSlave](Install-JenkinsSlave.ps1) downloads files and makes preparations for activation of the Jenkins Agent.

[Activate-JenkinsSlave](Activate-JenkinsSlave.ps1) registers the Jenkins Agent with the master, installs the Jenkins Agent a system service, and starts the service. After this, the agent is able to service jobs from the master.

[Uninstall-JenkinsSlave](Uninstal-JenkinsSlave.ps1) deregisters the Jenkins Agent with the master, stops the Jenkins Agent service, and removes it as a system server.
