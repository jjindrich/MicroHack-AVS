# MicroHack-AVS

## Build lab

Steps
- Run bicep to provision AVS + Jump VM (or use ELZ https://github.com/Azure/Enterprise-Scale-for-AVS)
```
az login
az deployment group create -g "avs-lab-rg" -f "requirements.avm.bicep" --parameters "requirements1.avm.bicep.parameters.json"
```
- Create users in Azure tenant based on template - 4 users per tenant
- Create group avsadmins with members
- Set contributor permissions for avsadmins group to subscription
- Set permissions for jumpbox managed identity to AVS (Contributor role)
- Create connection to AVS from Express Route
- deploy nested labs - scripts from https://github.com/microsoft/MicroHack/tree/main/03-Azure/01-03-Infrastructure/05_Azure_VMware_Solution/Lab/scripts
  - fill nestedlabs.yml with credentials
  - run bootstrap.ps1
  - run scheduled task or command

```pwsh
pwsh.exe -ExecutionPolicy Unrestricted -NonInteractive -NoProfile -WindowStyle Hidden -WorkingDirectory "c:\temp" -File "c:\temp\bootstrap-nestedlabs.ps1" -GroupId 1 -Labs 3
```
Check ESX is running on web:  https://10.<group_ip>.1.2/
username: administrator@avs.lab

## Challenges
Use this challenges from https://github.com/microsoft/MicroHack/tree/main/03-Azure/01-03-Infrastructure/05_Azure_VMware_Solution

Install application (app+sql) from https://github.com/tkubica12/MicroHack-AppInnovation/tree/main/baseInfra/scripts
