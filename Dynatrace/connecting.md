# Dynatrace ActiveGate

## Pre-Requisites

- Connected to the [VPN](https://portal.platform.hmcts.net)

## Connecting to Dynatrace VMs (ActiveGate)

- Dynatrace ActiveGate VMs exist as instances of different VMSS:
  - [Private PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-ptl-vmss)
  - [PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-ptl-vmss)
  - [Private Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-nonprod-vmss)
  - [Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-nonprod-vmss)


- Connections to these VMs are handled with SSH. Run the commands below in order to connect to a given VM, there is a script in `/bin/IPlist.sh` to list IP addresses of VMs.
```bash
  az keyvault secret download -f ~/.ssh/dt-key --vault-name cftptl-intsvc --name aks-ssh-private-key
  chmod 600 ~/.ssh/dt-key
  ssh -i ~/.ssh/dt-key azureuser@{replace_me_with_vm_ip}
```
