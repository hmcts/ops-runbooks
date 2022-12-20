# Redeploying AKS Clusters Runbook

This wiki page documents some tasks that we have to perform when deploying any of the AKS Clusters

## To create a cluster:

Go to the [CFT pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) or [SDS Pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=482&_a=summary) depending on which cluster you are deploying.

Click on **Run pipeline** (blue button) in top right of Azure DevOps. Ensure that Action is set to Apply, Cluster is set to which ever one you want to build and that the environment is selected from the drop down menu. 

Click on **Run** to start the pipeline.

## Deployment Order

This order can change; created to give a brief overview of the environments.

Redeploying in order:-

**CFT Clusters**
- sbox             - (K8s service names are  = cft-sbox-00-aks - cft-sbox-01-aks)
- Management sbox  - (K8s service name is    = cft-ptlsbox-00-aks)
- ITHC             - (K8s service names are  = cft-ithc-00-aks - cft-ithc-01-aks)
- Preview          - (K8s service name is    = cft-preview-01-aks)
- AAT              - (K8s service names are  = cft-aat-00-aks - cft-aat-01-aks)
- Production       - (K8s service names are  = prod-00-aks - prod-01-aks) 
- Management       - (K8s service name is    = cft-ptl-00-aks) 
- Perftest         - (K8s service names are  = cft-perftest-00-aks - cft-perftest-01-aks)
- Demo             - (K8s service names are  = cft-demo-00-aks - cft-demo-01-aks)

**SDS Clusters**
- sbox             - (K8s service names are  = ss-sbox-00-aks - ss-sbox-01-aks)
- Management sbox  - (K8s service name is    = ss-ptlsbox-00-aks)
- ITHC             - (K8s service names are  = ss-ithc-00-aks - ss-ithc-01-aks)
- STG              - (K8s service names are  = ss-stg-00-aks - ss-stg-01-aks)
- Production       - (K8s service names are  = ss-prod-00-aks - ss-prod-01-aks) 
- Management       - (K8s service name is    = ss-ptl-00-aks) 
- Demo             - (K8s service names are  = cft-demo-00-aks - cft-demo-01-aks)
- Test             - (K8s service names are  = ss-test-00-aks - ss-test-01-aks)
- Dev              - (K8s service names are  = ss-dev-01-aks)

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

* Stop the cluster and once the cluster has fully stopped take a snapshot of the disk referenced [here](https://github.com/hmcts/cnp-flux-config/blob/85d61449e8633c6a975798c01e7ce155c9861c7e/apps/jenkins/jenkins/sbox-intsvc/disk.yaml#L8) and ensure it is placed somewhere safe so that we can re-use this snapshot to re-create the jenkins disk after the cluster has been redeployed.

* Run this [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) to destroy the existing cluster, the environment is **PTLSBOX**.

* Run the same [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) again to apply to the cluster, the environment is **PTLSBOX**. 

* Once the pipeline to deploy the cluster has completed, refer to the snapshot previously taken and create a new disk from it named as **jenkins-disk** ensuring it is placed in the location referenced [here](https://github.com/hmcts/cnp-flux-config/blob/85d61449e8633c6a975798c01e7ce155c9861c7e/apps/jenkins/jenkins/sbox-intsvc/disk.yaml#L8).

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

- Change Jenkins to use the other cluster, e.g. [cnp-flux-config#19886](https://github.com/hmcts/cnp-flux-config/pull/19886/files) .
  - If not updated, you can change manually providing PR has been approved and merged [View Jenkins Configuration](https://build.platform.hmcts.net/configure)
- Swap external DNS active cluster, e.g. [cnp-flux-config#19889](https://github.com/hmcts/cnp-flux-config/pull/19889) 
- Create a test PR, normally we just make a README change to [rpe-pdf-service](https://github.com/hmcts/rpe-pdf-service) . [example PR](https://github.com/hmcts/rpe-pdf-service/pull/318)
  - Check this PR in Jenkins has successfully ran through stage [AKS deploy - preview](https://build.platform.hmcts.net/job/HMCTS_Platform/job/rpe-pdf-service/view/change-requests/job/PR-318/)
- Update the charts for jobs and steps pointing to the new preview [cnp-azuredevops-pipelines#127](https://github.com/hmcts/cnp-azuredevops-libraries/pull/127/files)
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
- Update Civil team's DNS entries to point to the active Jenkins cluster (until they switch to using platform-hmcts-net). [Update active jenkins-cluster IP value in DNS](https://github.com/hmcts/azure-private-dns/pull/428/files) and [update existing platform-hmcts-net entries](https://github.com/hmcts/azure-private-dns/pull/430/files).

### Production

#### Day or hours before deployment of a cluster  

It is important to identify applications with underlying issues and allow sufficient time for teams to acknowledge or fix issues before proceeding with cluster rebuild.
- Create a time-snapshot list of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A > all_pods_status_$TIMESTAMP`
- Create a time-snapshot count of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | wc -l > total_pods_$TIMESTAMP`  
- To identity failed Helm releases and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get hr -A | grep -v Succeeded > failed_hrs_$TIMESTAMP`  
- To identify failed pods and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | grep -v Completed | grep -v Running > failed_pods_$TIMESTAMP`
- Investigate failed helm releases and missing pods as required  
- For failed helm releases where pods are not deployed, test if rolling back to a previous release `helm rollback` is possible (which helps narrow down issue being specific to current release) 
- For failed pods, investigate root cause and discuss with teams as required (e.g. pods not starting due to missing keyvault secrets)

#### Before deployment of a cluster
- Remove the cluster you are going to be redeploying from the AGW. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/594)
- Unsure which IP belongs to which cluster? Check the front end IP of the kubernetes-internal loadbalancer

Every Production change which involves taking down a cluster is supposed to include scaling up of the apps (these can chan e):-
- idam-api (scale from 4 to 8)
- ccd-data-store-api (scale from 15 to 30)
- ccd-definition-store-api (scale from 4 to 8)
- dm-store (scale from 7 to 14)

*(idam-api requires 8 pods to be split up across 2 clusters and handle the load.  If we are bringing a cluster down then we need to ensure the other cluster has 8 pods for idam-api)*

This scaling is done via a PR [PR example here](https://github.com/hmcts/cnp-flux-config/pull/7245)
Scaling to happen just before a cluster has been removed from AGW. 
- Create PR to scale apps and merge. 
- Check cluster that won't be removed to confirm pods have scaled
- Merge PR to remove a cluster from AGW

#### After deployment of a cluster
- Check all pods are deployed and running. Compare with pods status reference taken pre-deployment  
- Speak to teams (where required) for any specific issues related to failed pods
- Ensure failed pods issues are either acknowledged by teams or fixed before rebuilding 2nd cluster.  This is to prevent a situation whereby applications are failed across both clusters after rebuild
- Add the cluster back into AGW once you have confirmed deployment has been successful. [PR example here](https://github.com/hmcts/azure-platform-terraform/pull/595)
- Revert merge for scaling pods & merge [PR example here](https://github.com/hmcts/cnp-flux-config/pull/7245)
- Confirm pods are back to correct numbers after revert

### Management (cftptl-intsvc)

Anything configuration wise i.e jobs, secrets, and config is stored externally from the Jenkins server, no requirement to back up the server.
See https://github.com/hmcts/cnp-flux-config/blob/master/apps/jenkins/jenkins/ptl-intsvc/jenkins.yaml

#### Before deployment of a cluster

- Make an announcement that Jenkins will be unavailable. This environment is best to be done early in the morning. Example announcement to send in the cloud-native-announce slack channel is:-

> Hi @here,
> Due to planned upgrades of AKS, we will be upgrading the management (cftplt-intsvc) cluster at 8am, Monday 26th April. As a result of this, Jenkins will be offline during the upgrade and > unavailable for around one hour.>

* Run the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Destroy, Cluster is set to cluster you plan to destroy and Environment is set to **PTL** before clicking on **Run**. 

* Run the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Apply, Cluster is set to cluster you plan to build and Environment is set to **PTL** before clicking on **Run**. 

#### After deployment of a cluster

After the cluster has been redeployed successfully and hr's / pods are running as expected you need to verify that you can get to the [Jenkins web ui](https://build.platform.hmcts.net), and then comment on the slack channel announcement made previously to advise Jenkins is back up.

### Perftest

#### Day or hours before deployment of a cluster  

It is important to identify applications with underlying issues and allow sufficient time for teams to acknowledge or fix issues before proceeding with cluster rebuild.
- Create a time-snapshot list of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A > all_pods_status_$TIMESTAMP`
- Create a time-snapshot count of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | wc -l > total_pods_$TIMESTAMP`  
- To identity failed Helm releases and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get hr -A | grep -v Succeeded > failed_hrs_$TIMESTAMP`  
- To identify failed pods and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | grep -v Completed | grep -v Running > failed_pods_$TIMESTAMP`
- Investigate failed helm releases and missing pods as required  
- For failed helm releases where pods are not deployed, test if rolling back to a previous release `helm rollback` is possible (which helps narrow down issue being specific to current release) 
- For failed pods, investigate root cause and discuss with teams as required (e.g. pods not starting due to missing keyvault secrets)
- For pods where images beginning with *pr-* aren't found (has been seen quite a few times on previous cluster rebuilds) this is often due to the image no longer existing in the ACR. In these instances you will need to either reach out to the app teams to get it updated or find the latest prod image for that pod in the ACR and put in a PR to fix like this one done previously - https://github.com/hmcts/cnp-flux-config/pull/17115/files.

#### Before deployment of a cluster

- Confirm that the environment isn't being used with Nickin Sitaram before starting. 
- Use slack channel pertest-cluster for communication.
- Scale the number of active nodes, increase by 5 nodes if removing a custer. 
  Reason for this CCD and IDAM will auto-scale the number of running pods when a cluster is taken out of service for a upgrade.

#### After deployment of a cluster
- Check all pods are deployed and running. Compare with pods status reference taken pre-deployment
### Demo

#### Day or hours before deployment of a cluster  

It is important to identify applications with underlying issues and allow sufficient time for teams to acknowledge or fix issues before proceeding with cluster rebuild.
- Create a time-snapshot list of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A > all_pods_status_$TIMESTAMP`
- Create a time-snapshot count of pods for comparison reference post-deployment - `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | wc -l > total_pods_$TIMESTAMP`  
- To identity failed Helm releases and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get hr -A | grep -v Succeeded > failed_hrs_$TIMESTAMP`  
- To identify failed pods and copy list into a file, run `TIMESTAMP="$(date +%F_%H%M%S)" && kubectl get pods -A | grep -v Completed | grep -v Running > failed_pods_$TIMESTAMP`
- Investigate failed helm releases and missing pods as required  
- For failed helm releases where pods are not deployed, test if rolling back to a previous release `helm rollback` is possible (which helps narrow down issue being specific to current release) 
- For failed pods, investigate root cause and discuss with teams as required (e.g. pods not starting due to missing keyvault secrets)
- For pods where images beginning with *pr-* aren't found (has been seen quite a few times on previous cluster rebuilds) this is often due to the image no longer existing in the ACR. In these instances you will need to either reach out to the app teams to get it updated or find the latest prod image for that pod in the ACR and put in a PR to fix like this one done previously - https://github.com/hmcts/cnp-flux-config/pull/17115/files.

#### Before deployment of a cluster

Demo runs only one cluster at a time due to some limitations in the current setup. 

- Check whether all deployments/ apps are up. `kubectl get hr -A` gives a quick snapshot of progress.
- Swap backend application gateway in [azure-platform-terraform](https://github.com/hmcts/azure-platform-terraform/pull/622/files)
- Swap active external dns deployments to route traffic to new cluster [Example PR](https://github.com/hmcts/cnp-flux-config/pull/14659/files)
- Delete inactive cluster using the [Pipeline](https://dev.azure.com/hmcts/CNP/_build?definitionId=483&_a=summary) ensuring Action is set to Destroy, Cluster is set to cluster you plan to destroy and Environment is set to that you intend to run against before clicking on **Run**.

#### After Deployment of Cluster
- Check all pods are deployed and running. Compare with pods status reference taken pre-deployment

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
