# On call

This folder describes access requirements and how to do common tasks when a person is on-call.

It is required that you go through this document before going on-call, and verify you have access to all components. 

## Azure Active Directory Groups

You must be in the following groups:

* DTS Platform Operations

You can add yourself via the [devops-azure-aad GitHub repo](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml).

## Connecting to services

Before you go on call you need to make sure you have access to each service

### CFT Kubernetes

CFT has two prod kubernetes clusters, the current login command is:

```bash
az login
az aks get-credentials --resource-group cft-prod-00-rg --name cft-prod-00-aks --subscription DCD-CFTAPPS-PROD --overwrite
az aks get-credentials --resource-group cft-prod-01-rg --name cft-prod-01-aks --subscription DCD-CFTAPPS-PROD --overwrite

kubectl get pods -n admin
# this will prompt you to login via Azure Active Directory
# after your login verify you can restart a pod, e.g. fluxcloud (admin notifying service, downtime doesn't matter)
kubectl delete pod -n admin -l app=fluxcloud
```
The default configuration for an application is two pods on each cluster, but teams may have more.


### IDAM access

Idam is accessed via a bastion server of its own, also known as the idam jump box. Follow the below steps for access via the production bastion server.

1. Request time based access (Automatically approved)

Navigate to https://myaccess.microsoft.com/
* Select: Production Bastion Server Access followed by "+ Request Access"
* Select: On-Call policy, no business justification is required.
* Request: For specific period: Enter the period you are on-call for.
* Submit (A green notification will confirm this was successful).

2. Download `devops-sshkey-privatekey` and set permissions
```bash
az keyvault secret download -f ~/.ssh/cft-idam --vault-name idamvaultprod --name devops-ssh-privatekey
chmod 600 ~/.ssh/cft-idam
```
3. Retrieve passphrase for IDAM SSH key and add RSA identity. 
```bash
az keyvault secret show --vault-name idamvaultprod --name devops-sshkey-passphrase --query value -o tsv
ssh-add ~/.ssh/cft-idam # paste the output of the previous command for the passphrase
```
4. Open the `~/.ssh/config` file (create if it doesn't already exist) and add the below:

**Add your own username to line 3**
```bash
# Bastion - DevOps production access
Host prodbastion
HostName bastion-prod.platform.hmcts.net
User {AD USERNAME HERE}@hmcts.net # this must be all in lowercase.
DynamicForward 10825
ForwardAgent yes
KeepAlive yes
ServerAliveInterval 60
```
5. Connect to HMCTS [VPN](https://portal.platform.hmcts.net/)

Connect with:
```bash
ssh prodbastion
```

Follow the on-screen instructions to authenticate with yout HMCTS credentials.

6. Connect to IDAM Jump server
```bash
ssh devops@idam-bastion.platform.hmcts.net
```

**Note:** In the event of an emergency, you can bypass the first bastion server from Step 5 by adding your home IP address to the NSG [core-infra-idam-prod2-jumpbox-nsg](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/8999dec3-0104-4a27-94ee-6588559729d1/resourceGroups/core-infra-idam-prod2/providers/Microsoft.Network/networkSecurityGroups/core-infra-idam-prod2-jumpbox-nsg/inboundSecurityRules). You will find the public IP attached to idam-prod2-jumpbox VM in Azure.

**Note:** there is a DNS name idam-bastion.platform.hmcts.net, but some people have had issues connecting using it. Local IP is: `10.106.79.4`.

The [idam-tools](https://github.com/hmcts/idam-tools) repository is checked out in the home directory of the `devops` user.
There's useful scripts there.

You can also jump from this server to the other ones, you will need to provide the SSH key passphrase each time you log in.

```command
ssh idam@forgerock-idm-1
ssh idam@forgerock-idm-2
ssh idam@forgerock-idm-3
```
