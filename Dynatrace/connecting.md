# Dynatrace

## Pre-Requisites

- Connected to [F5](https://portal.platform.hmcts.net)

## Connecting to Dynatrace VMs (ActiveGate)

- Dynatrace ActiveGate VMs exist as instances of different VMSS:
* [Private PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-ptl-vmss)
* [PTL](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-ptl-vmss)
* [Private Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-private-nonprod-vmss)
* [Nonprod](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_Compute/VirtualMachineScaleSet/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/aks-infra-cftptl-intsvc-rg/providers/Microsoft.Compute/virtualMachineScaleSets/activegate-nonprod-vmss)

- Connections to these VMs are handled with SSH. The ssh private-key can be found in the [cftptl-intsvc](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.KeyVault/vaults/cftptl-intsvc/secrets) Key Vault (for each VM instance in each environment).
Run the commands below in order to connect to a given VM.
  - az account set --subscription DTS-CFTPTL-INTSVC
  - az keyvault secret download -f dt-key --id https://cftptl-intsvc.vault.azure.net/secrets/aks-ssh-private-key/0ea947804a1142eab4c08c27de813e49; echo "\n" >> dt-key
  - chmod 600 dt-key
  - ssh -i dt-key azureuser@{replace_me_with_vm_ip}
