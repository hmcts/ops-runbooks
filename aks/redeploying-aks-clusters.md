# Redeploying AKS Clusters Runbook

This wiki page documents some tasks that we have to perform when deploying any of the AKS Clusters

## To create a cluster:

Go to the [pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary). 

Click on **Run pipeline** (blue button) in top right of Azure DevOps. Ensure that Action is set to Apply, Cluster is set to which ever one you want to build and that the environment is selected from the drop down menu. 

Click on **Run** to start the pipeline.

## Deployment Order

This order can change; created to give a brief overview of the environments.

Redeploying in order:-

- sbox
- Management sbox (cftsbox-intsvc)
- ITHC
- Preview 
- AAT
- Production
- Management (cftptl-intsvc)
- Perftest
- Demo

## Dashboards
A good indication along with reviewing the environments themselves, reviewing Grafana
[Grafana Sandbox](grafana.sandbox.platform.hmcts.net)
[Grafana](https://grafana-ptl.platform.hmcts.net/)

##  Environment specifics

Some environments do have some additional requirements/checks that need to confirmed prior to deploying any of its clusters.

### Sandbox

N/A

### Management Sandbox

#### Before deployment of a cluster

As this environment only tends to be used by IDAM, you need to confirm with Paul Verity that the Sandbox Jenkins instance which sits on this cluster isn't being used and that he is ok with the work to go ahead. The sandbox Jenkins instance can be logged into [here](https://sandbox-build.platform.hmcts.net/).

Confirm that the [cnp-plum-recipes-service](https://sandbox-build.platform.hmcts.net/job/HMCTS_Sandbox_CNP/job/cnp-plum-recipes-service/job/master/) job within Jenkins runs successfully.


* Run this [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) to destroy the existing cluster, the environment is **PTLSBOX**.

* Run the same [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) again to apply to the cluster, the environment is **PTLSBOX**. 

#### After deployment of a cluster

Once the cluster has been redeployed and Jenkins is back up and running, test the [cnp-plum-recipes-service](https://sandbox-build.platform.hmcts.net/job/HMCTS_Sandbox_CNP/job/cnp-plum-recipes-service/job/master/) job again to confirm it runs successfully as it did before (it should).

### ITHC

#### Before deployment of a cluster
- Remove the cluster you are going to redeploying from the AGW. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/546)
- Unsure which IP belongs to which cluster? Check the front end IP of the kubernetes-internal loadbalancer

#### After deployment of a cluster
- Add the cluster back into AGW once you have confirmed deployment has been successful. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/560)


### Preview

We have the ability to create another preview cluster on demand. We don't run with two at a time as they're 75 node clusters and that would be quite expensive.

#### When the build has finished

- Check the system helm releases and pods are up: flux, flux-helm-operator, tunnelfront, coredns, nodelocaldns, - aad-pod-identity, traefik
- Check an external IP has been assigned: kubectl get service -n admin |awk '$4 ~ /^[0-9]/'
- Check OSBA is running, kubectl get pods -n osba, kubectl get pods -n catalog

#### How to test a specific Preview cluster without swapping over
https://github.com/hmcts/cnp-plum-recipes-service/pull/379/files

https://github.com/hmcts/cnp-jenkins-library/compare/preview01?expand=1

This will simulate a repo/setup is using the Preview cluster that has not been swapped, useful to test if required.
Same PR might not be re-usable when the cluster is swapped to active as DNS record could be invalid. You can verify and manually tweak the records to be able to reuse it.
#### After deployment of a cluster

- Change Jenkins to use the other cluster, e.g. [cnp-flux-config#4348](https://github.com/hmcts/cnp-flux-config/pull/4348) .
  - If not updated, you can change manually providing PR has been approved and merged [View Jenkins Configuration](https://build.platform.hmcts.net/configure)
- Swap external DNS active cluster, e.g. [cnp-flux-config#4606](https://github.com/hmcts/cnp-flux-config/pull/4606) 
- Create a test PR, normally we just make a README change to [rpe-pdf-service](https://github.com/hmcts/rpe-pdf-service) . [example PR](https://github.com/hmcts/rpe-pdf-service/pull/318)
  - Check this PR in Jenkins has successfully ran through stage [AKS deploy - preview](https://build.platform.hmcts.net/job/HMCTS_Platform/job/rpe-pdf-service/view/change-requests/job/PR-318/)
- Update the charts for jobs and steps pointing to the new preview [cnp-azuredevops-pipelines#40](https://github.com/hmcts/cnp-azuredevops-libraries/pull/40)
- Send across the comms on #cloud-native-announce channel regarding the swap over to the new preview cluster, see below example annoucenment:-

Hi all, Preview cluster has been swapped cft-preview-00-aks.
Login using:
```command
az aks get-credentials --resource-group cft-preview-00-rg --name cft-preview-00-aks --subscription DCD-CFTAPPS-DEV --overwrite
```

* Delete all ingress on the old cluster to ensure external-dns deletes it's existing records:

```command
kubectl delete ingress --all-namespaces -l app.kubernetes.io/managed-by=Helm
```

* Delete any orphan records that external-dns might have missed:

_Replace 10.12.79.250 with the loadbalancer IP (kubernetes-internal) of the cluster you want to cleanup_
```command
az network private-dns record-set a list --zone-name service.core-compute-preview.internal -g core-infra-intsvc-rg --subscription DTS-CFTPTL-INTSVC --query "[?aRecords[0].ipv4Address=='10.12.79.250'].[name]" -o tsv | xargs -I {} -n 1 -P 8 az network private-dns record-set a delete --zone-name service.core-compute-preview.internal -g core-infra-intsvc-rg --subscription DTS-CFTPTL-INTSVC --yes --name {}
```

Once swap over is fully complete then delete the older cluster,

* Run the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Destroy, Cluster is set to cluster you plan to destroy and Environment is set to that you intend to run against before clicking on **Run**. 
### AAT

#### Before deployment of a cluster
- Remove the cluster you are going to redeploying from the AGW. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/580)
- Unsure which IP belongs to which cluster? Check the front end IP of the kubernetes-internal loadbalancer
- Change Jenkins to use the other cluster that is not going to be redeployed, e.g. [PR example here](https://github.com/hmcts/cnp-flux-config/pull/7138/files) .
  - If not updated, you can change manually providing PR has been approved and merged [View Jenkins Configuration](https://build.platform.hmcts.net/configure)

#### After deployment of a cluster
- Add the cluster back into AGW once you have confirmed deployment has been successful. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/582)

### Production

#### Before deployment of a cluster
- Remove the cluster you are going to redeploying from the AGW. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/594)
- Unsure which IP belongs to which cluster? Check the front end IP of the kubernetes-internal loadbalancer

Every Production change which involves taking down a cluster is supposed to include scaling up of the apps:-
- idam-api 
- ccd-data-store-api
- ccd-definition-store-api 
- dm-store

*(idam-api requires 8 pods to be split up across 2 clusters and handle the load.  If we are bringing a cluster down then we need to ensure the other cluster has 8 pods for idam-api)*

This scaling is done via a PR [PR example here](https://github.com/hmcts/cnp-flux-config/pull/7245)
Scaling to happen just before a cluster has been removed from AGW. 
- Create PR to scale apps and merge. 
- Check cluster that won't be removed to confirm pods have scaled
- Merge PR to remove a cluster from AGW

#### After deployment of a cluster
- Add the cluster back into AGW once you have confirmed deployment has been successful. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/595)
- Revert merge for scaling pods & merge [PR example here](https://github.com/hmcts/cnp-flux-config/pull/7245)
- Confirm pods are back to correct numbers after revert

### Management (cftptl-intsvc)
- Make an announcement that Jenkins will be unavailable. This environment is best to be done early in the morning. Example announcement to send in the cloud-native-announce slack channel is:-

> Hi @here,
> Due to planned upgrades of AKS, we will be upgrading the management (cftplt-intsvc) cluster at 8am, Monday 26th April. As a result of this, Jenkins will be offline during the upgrade and > unavailable for around one hour.>

* Run the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Destroy, Cluster is set to cluster you plan to destroy and Environment is set to **PTL** before clicking on **Run**. 

* Run the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Apply, Cluster is set to cluster you plan to build and Environment is set to **PTL** before clicking on **Run**. 


#### After deployment of a cluster

After the cluster has been redeployed successfully and hr's / pods are running as expected you need to verify that you can get to the [Jenkins web ui](https://build.platform.hmcts.net), and then comment on the slack channel announcement made previously to advise Jenkins is back up.

### Perftest
- Confirm that the environment isn't being used with Nickin Sitaram before starting. 

### Demo

Demo runs only one cluster at a time due to some limitations in the current setup. 

- Check whether all deployments/ apps are up. `kubectl get hr -A` gives a quick snapshot of progress.
- Swap backend application gateway in [azure-platform-terraform](https://github.com/hmcts/azure-platform-terraform/pull/622/files)
- Swap active external dns deployments to route traffic to new cluster [Example PR](https://github.com/hmcts/cnp-flux-config/pull/7522/files)
- Delete inactive cluster using the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Destroy, Cluster is set to cluster you plan to destroy and Environment is set to that you intend to run against before clicking on **Run**.

#### After Deployment of Cluster

* Delete all ingress on the old cluster to ensure external-dns deletes it's existing records:

```command
kubectl delete ingress --all-namespaces -l app.kubernetes.io/managed-by=Helm
```
## Known issues

### Neuvector

1. `admission webhook "neuvector-validating-admission-webhook.neuvector.svc" denied the request:`, these alerts can be seen on `aks-neuvector-<env>` slack channels
   - This happens when neuvector is broken. 
   - Check events and status of neuvector helm release. 
   - Delete Neuvector Helm release to see if it comes back fine.
2. Neuvector fails to install.
   - Check if all enforcers come up in time, they could fail to come if nodes are full.
   - If they keep failing with race conditions, it could be due to backups being corrupt.
   - Usually `policy.backup` and `admission_control.backup` are the ones you need to delete from Azure file share if they are corrupt.
