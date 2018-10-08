# Plastic SCM installation scripts

These scripts install and configure the Plastic SCM client.

We use Plastic SCM (Cloud Edition). All our repositories are in Plastic Cloud. The Plastic client needs to be assigned a user account + password and given the content encryption password for the Cloud organization.

Plastic has a `clconfigureclient` command. It is intended for configuration of Plastic SCM clients against non-Cloud Plastic servers; it won't work for configuring access to Plastic Cloud accounts. The `clconfigureclient` command does not set up content encryption passwords either. Therefore these scripts create all config files manually.

# Script index

[Install-Plastic](Install-Plastic.ps1) downloads and installs a specific version of the Plastic SCM client (Cloud Edition).

[Activate-Plastic](Activate-Plastic.ps1) configures the Plastic SCM client to log in to an organization in Plastic Cloud.
