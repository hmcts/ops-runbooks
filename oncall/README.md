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
