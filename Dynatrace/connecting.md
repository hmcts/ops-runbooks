# Dynatrace

## Pre-Requisites

- Connected to [F5](https://portal.platform.hmcts.net)

## Connecting to Dynatrace VMs (ActiveGate)

- Dynatrace ActiveGate VMs exist as instances of different VMSS:
* [Private PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-ptl-vmss)
* [PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-ptl-vmss)
* [Private Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-nonprod-vmss)
* [Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-nonprod-vmss)

- Connections to these VMs are handled with SSH. The ssh private-key can be found in the [cftptl-intsvc](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.KeyVault/vaults/cftptl-intsvc/secrets) Key Vault (for each VM instance in each environment). Copy the value of `aks-ssh-private-key` to your local machine, and then folow the instructions in the `Connect` section of a given VMSS instance to connect.