# On call

This folder describes access requirements and how to do common tasks when a person is on-call

## Azure Active Directory Groups

You must be in the following groups:

* dcd_group_devops_v2
* dcd_platformengineering
* dcd_group_aks_admin_dcd-cftapps-prod_v2
* dcd_group_sub_reader_dcd-cftapps-prod_v2

You can add yourself via the [devops-azure-aad GitHub repo](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml).

## Connecting to services

Before you go on call you need to make sure you have access to each service

### CFT Kubernetes

CFT has two prod kubernetes clusters, the current login command is:

```bash
az login
az aks get-credentials --resource-group prod-00-rg --name prod-00-aks --subscription DCD-CFTAPPS-PROD --overwrite
az aks get-credentials --resource-group prod-01-rg --name prod-01-aks --subscription DCD-CFTAPPS-PROD --overwrite

kubectl get pods -n admin
# this will prompt you to login via Azure Active Directory
# after your login verify you can restart a pod, e.g. fluxcloud (admin notifying service, downtime doesn't matter)
kubectl delete pod -n admin -l app=fluxcloud
```
The default configuration for an application is two pods on each cluster, but teams may have more.


### IDAM access

Idam is accessed via a bastion server, also known as the idam jump box. Follow the below steps for access instructions.

1. Request time based acces (Automatically approved)

Navigate to Navigate to: https://myaccess.microsoft.com/@CJSCommonPlatform.onmicrosoft.com#/access-packages

Select: DevOps Bastion Server Access followed by "Request Access"
Select: On-Call policy, no business justification is required.
Request: For specific period: Enter your on-call shift dates.
Submit (A green notification will confirm this was successful).

2. Download devops-sshkey-privatekey and set permissions
```bash
az keyvault secret download -f ~/.ssh/cft-idam --vault-name idamvaultprod --name devops-ssh-privatekey
chmod 600 ~/.ssh/cft-idam
```
3. Display devops-sshkey-passphrase and add RSA identity. 
```bash
az keyvault secret show --vault-name idamvaultprod --name devops-sshkey-passphrase --query value -o tsv
ssh-add ~/.ssh/cft-idam # paste the output of the previous command for the passphrase
```
4. Open the ~/.ssh/config file (create if it doesn't already exist) and add the below:
**add your own username to line 3**
```bash
# Bastion - DevOps production access
Host prodbastion
HostName bastion-devops-prod.platform.hmcts.net
User {AD USERNAME HERE}@hmcts.net
DynamicForward 10825
ForwardAgent yes
KeepAlive yes
ServerAliveInterval 60
```
5. Connect to HMCTS VPN here: https://portal.platform.hmcts.net/
Connect with:
```bash
ssh prodbastion
```
6. Connect to IDAM Jump server
```bash
ssh devops@idam-bastion.platform.hmcts.net
```

**Note:** there is a DNS name idam-bastion.platform.hmcts.net, but some people have had issues connecting using it. Local IP is: 10.106.79.4

The [idam-tools](https://github.com/hmcts/idam-tools) repository is checked out in the home directory of the `devops` user.
There's useful scripts there.

You can also jump from this server to the other ones, you will need to provide the SSH key passphrase each time you log in.

```command
ssh idam@forgerock-idm-1
```
