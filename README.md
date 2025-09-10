# MicroHack-AVS

## Build lab

Steps
- run bicep to provision AVS + Jump VM (or use ELZ https://github.com/Azure/Enterprise-Scale-for-AVS)
- create users in Azure Subscription
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
