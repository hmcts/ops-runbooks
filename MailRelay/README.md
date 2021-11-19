# Exim Mailrelay

This runbook describes how to deploy a new Exim image to the Dev and Production Environments. The current version of mairelay is <b>0.2.8</b>. Mailrelay configurations are managed through the following repo [exim-relay](https://github.com/hmcts/exim-relay).

## Prerequisites

* GitHub write access to [Exim-Relay](https://github.com/hmcts/exim-relay)
* Azure DevOps access to [Exim-Relay Pipeline](https://dev.azure.com/hmcts/Shared%20Services/_build?definitionId=503)

If you are working with the Exim-Exporter you will need write access to the following 
* GitHub write access to [Exim-Exporter](https://github.com/hmcts/exim-relay)
* Azure Devops access to [Exim Exporter Pipeline](https://dev.azure.com/hmcts/Shared%20Services/_build?definitionId=504)
## Mailrelay Essentials

1. What is Mailrelay and What is it used for? 

Exim Mail Relay is a Mail Transfer Agent, its main purpose is to receive emails from an Mail User Agent (MUA) and relays the email to other MTAs or a Mail Delivery Agent . In HMCTS it used by PCOL and MCOl to send emails to clients.  

Exim Mailrelay is currently deployed in SS-dev-00 / SS-dev-01 / SS-prod-00 / SS-prod-01. Mailrelay is monitored using Prometheus and Grafana. Alerts are sent to the following Slack channel #prometheus-alerting-prod , #prometheus-alerts, #prometheus-critical. 

2. Modifying the exim.conf File 

The exim.conf file is written with makefile, you can find more information in the [makefile tutorial](https://makefiletutorial.com/)

*more to be added*

3. Authentication Mechanisms 
   
Client applications use TLS to authenticate to the Mailrelay server to be able to send emails. The server has inbound and outbound certs. Certifcates are generated using the [ACME Function App](https://github.com/hmcts/ops-runbooks/tree/master/Certificates)

*more to be added*

## Deployment
A PR for changes to the EXIM relay or Exim Exporter. The Platform Operations will review the PR and provide approval, followed by executing the pipeline on behalf of the requester. 

1. Clone Exim-Relay 

2. After making changes to the Mailrelay configuration review PR and provide approval as appropriate.
   * While making the Pull Request please ensure that the base repo is hmcts/ exim-relay and not luigibk/exim-relay

3. Pipeline 
   * The pipeline will run after making a PR or merging to master and will build an image in the Azure Container Repository [here](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-acr-rg/providers/Microsoft.ContainerRegistry/registries/sdshmctspublic/repository)

     *   The Service connection used for the pipeline is DTS SS Public Prod

4. Configuring Shared-Service-Flux 

In order to deploy to your latest image to the Dev or Production environment flux needs to know the image it needs to look for. 
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* Clone the shared-services-flux [repo](https://github.com/hmcts/shared-services-flux) 
* change the tag to the latest tag number in the [patches file](https://github.com/hmcts/shared-services-flux/tree/master/k8s/release/mailrelay/mailrelay/patches)  
* Add and Commit changes  
* Review as required
* Merge branch with Master.
* After 5 to 10 minutes check the deployments have been updated on the cluster. 

## Testing Mailrelay 

After making changes to Exim.conf you may need to test that emails are going through according to the authentication mechanism that you have set to be advertised by the host. 

### Test unauthneticated relay, determine if unauthenticated relay is on or off

1. Spin up a temporary pod in the Kubernetes Cluster
```bash
kubectl run -it --rm --restart=Never -n admin --image=docker.io/infoblox/dnstools:latest dnstools --command -- /bin/sh
```
2. Add additional tools, this includes telnet 
```bash
apk add busybox-extras
```
3. Get the IP address, 
```bash
Kubectl get svc -n <namespace>
```

4. Send email from pcol to chosen email 
```bash
telnet <ip:port>
helo possessionclaim.gov.uk
mail from: noreply-pcol@hmcts.net
rcpt to: <recipient email>
data
354 Enter message, ending with "." on a line by itself
data
Subject: test                                         
test test test
```
* Note - unauthenticated relay should be turned off and you should receive a 550 unauthenticated relay response 
### Test TLS connection using SWAKS 
```bash
    kubectl run my-shell -it --rm --restart=Never -n admin --image=ubuntu --command -- bash
    apt update
    apt install swaks
    apt install telnet
    swaks -a -tls -q HELO -s <ip>-au v1test -ap '<password'
```

### Test StartTLS connection using OpenSSL
```bash
Turn user name and password to base 64 

echo -ne '<password>' | base64

Connect to Mailrelay using StartTLS 

openssl s_client -connect ip:port -starttls smtp

Send Email 
```bash
helo possessionclaim.gov.uk
mail from: noreply-pcol@hmcts.net
rcpt to: <email>
data
Subject: test 
test test test
.
```

## Monitoring MailRelay 
Pre requisites 

* GitHub write access to [Exim-Exporter](https://github.com/hmcts/exim-relay)
* Azure Devops access to [Exim Exporter Pipeline](https://dev.azure.com/hmcts/Shared%20Services/_build?definitionId=504)

Prometheus 
* The Prometheus server (Monitoring Namespace) is used to obtain metrics from the exim server and exports them using the Exim-Exporter tool
* The exim exporter tool is a 3rd party tool, the official github for the tool can be found [here](https://github.com/gvengel/exim_exporter), the forked hmcts version can be found [here](https://github.com/hmcts/exim_exporter)  
* The Exim Exporter is a third party rool which is exposed as a service, it obtains metrics and sends it to the Prometheus server 
* The Alert Manager (Monitoring Namespace) takes these metrics and sends it to specified Slack Channels. 
* If you need to add alerts or tweak current alerts you can do so [here](https://github.com/hmcts/shared-services-flux/blob/master/k8s/namespaces/monitoring/kube-prometheus-stack/patches/dev/cluster-00/mailrelay-alerts-rules.yaml) 

Grafana 

*more to be added*
## Troubleshooting Common Errors 

Alerts are not being sent to Slack 

* Check alert logs 
```bash
kubectl exec --stdin --tty alertmanager-kube-prometheus-stack-alertmanager-0   -n monitoring -- /bin/sh

kubectl logs -f -c alertmanager alertmanager-kube-prometheus-stack-alertmanager-0 -n monitoring

kubectl logs -f -c alertmanager alertmanager-kube-prometheus-stack-alertmanager-0 -n monitoring > alertmanager-logs.log
```

* Make post request 
```bash
wget --header "content-type: application/json" --post-data '[{"status": "firing","labels": {"alertname": "EximQueueLength","service": "mailrelay","severity": "warning","instance": "0"}}]' http://localhost:9093/api/v1/alert
```

*more to be added*
## Performance Testing 

*more to be added*
## Onboarding & Migrating Customers 

*more to be added*
## Further Links 

* https://www.exim.org/docs.html

* https://serverfault.com/

* https://alanstorm.com/what-are-prometheus-exporters/

* https://prometheus.io/docs/instrumenting/exporters/
