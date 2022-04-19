# Globalscape / EFT Enterprise

This readme describes a bit about the Globalscape EFT service and how you can access the two VM's running it.

## Description

Service Description TBA



## Prerequisites

* Enable JIT access to Production Bastion, you can do that [here](https://myaccess.microsoft.com/).
* Connect to [F5](https://portal.platform.hmcts.net). 

As an alternative to below you can run the `globalscape-eft.sh` file on your local machine, just download the file and run `chmod +x globalscape-eft.sh;./globalscape-eft.sh`.


## Connecting to Bastion

You need to connect to Bastion to port forward your traffic to the EFT VMs. In your shell, run the following command:

```
az ssh config --ip \*.platform.hmcts.net --file ~/.ssh/config
```

## Port forwarding via Bastion

To port forward to the EFT VM, run the following command replacing the variable with the intended IP. You can find the IP by going to either the [rdo-sftp-eft-0](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/0978315c-75fe-4ada-9d11-1eb5e0e0b214/resourceGroups/RDO-HUB-SFTP-PROD/providers/Microsoft.Compute/virtualMachines/rdo-sftp-eft-0/overview) or [rdo-sftp-eft-1](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/0978315c-75fe-4ada-9d11-1eb5e0e0b214/resourceGroups/RDO-HUB-SFTP-PROD/providers/Microsoft.Compute/virtualMachines/rdo-sftp-eft-1/overview) resource, clicking Connect > RDP > IP address (Private IP).

```
ssh -L 5555:{VM-PRIVATE-IP}:3389 bastion-prod.platform.hmcts.net
```

This will leave you connected in the bastion shell, which means you're ready to connect to the EFT VMS. You can replace `5555` here with a port of your choice on your machine if you wish.

## Connecting to the VM

For the next step you'll need some RDP software on your machine, you can use `Windows Remote Desktop` for instance. Now you need to connect to `localhost:5555`, the port opened in the previous step to forward traffic to the EFT VM. The [username](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_KeyVault/Secret/https://rdo-ftps-kvs.vault.azure.net/secrets/admin-username) and [password](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_KeyVault/Secret/https://rdo-ftps-kvs.vault.azure.net/secrets/sftpadmin) can be found [here](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/0978315c-75fe-4ada-9d11-1eb5e0e0b214/resourceGroups/rdo-hub-sftp-prod/providers/Microsoft.KeyVault/vaults/rdo-ftps-kvs/secrets). 

## Troubleshooting

In the bottom left open the Windows control panel and click `Server Manager`. You can also view logs and configuration in the `EFT Enterprise Application`. 

More TBA.

