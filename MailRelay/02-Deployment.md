
Step 1 - Build New Image 
Azure Devops Project - Shared services 

Service Connection - DTS SS Public Prod

Main Pipeline - Hmcts .exim-relay

Exim Exporter Pipeline - Hmcts.exim-exporter

https://dev.azure.com/hmcts/Shared%20Services/_build?definitionId=503&_a=summary

https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e[…]osoft.ContainerRegistry/registries/sdshmctspublic/repository

Step 2 - Update Shared Services Flux 

Repo: https://github.com/hmcts/shared-services-flux 

Update tag value here https://github.com/hmcts/shared-services-flux/blob/master/k8s/release/mailrelay/mailrelay/patches/dev/cluster-00/mailrelay.yaml

Step 3 - Check 

After 5 minutes or so check that the Helm Release and and Pods are functioning again with the new image using Kubectl get pods <pod-name> -n mailrelay2 