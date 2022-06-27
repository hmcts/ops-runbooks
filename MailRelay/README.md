# Mailrelay v2

This runbook describes how Mailrelay is configured and deployed and the steps that are necessary to on-board new clients. The Mailrelay configuration can be found in the repo [exim-relay](https://github.com/hmcts/exim-relay).

## How to On-board Clients

Each service will require a username and password to utilise the Mailrelay service and these will be stored in Key Vault ([Dev: sds-mailrelay-dev](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/867a878b-cb68-4de5-9741-361ac9e178b6/resourceGroups/sds-mailrelay-dev-rg/providers/Microsoft.KeyVault/vaults/sds-mailrelay-dev/secrets), [Prod: sds-mailrelay-prod](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-mailrelay-prod-rg/providers/Microsoft.KeyVault/vaults/sds-mailrelay-prod/overview)). The Username will be the service name; the password should be randomly generated and be sufficiently complex.

1. Create a new secret in Key Vault and associate a complex password
2. Branch off the [Flux](https://github.com/hmcts/sds-flux-config) repo, edit the configuration file [mailrelay2.yaml](https://github.com/hmcts/sds-flux-config/blob/master/k8s/release/mailrelay/mailrelay2/patches/prod/cluster-00/mailrelay2.yaml) then append the new service account to the section authKeyVaultSecrets.

The syntax is as follows:

```authKeyVaultSecrets:
     - "my-service-user-account"
     - "mailrelay-prod-user"
```

3. Create a new pull request and merge into the master branch once approved
4. Test access and connectivity as described in the section below [Testing Mailrelay](#testing-mailrelay)

## What is Mailrelay and what is it used for?

Exim Mail Relay is a Mail Transfer Agent, its main purpose is to receive emails from a Mail User Agent (MUA) and relay the email to other MTAs or a Mail Delivery Agent .

### Mailrelay AKS deployment

An Exim Mailrelay container is built via Docker and stored in the ACR Azure image repository. It's based on the featherweight image Alpine as defined in the git repo [Docker Exim Relay Image](https://github.com/hmcts/exim-relay) and is built via an Azure DevOps pipeline.

Exim Mailrelay is currently deployed on AKS in SS-dev-00 / SS-dev-01 / SS-prod-00 / SS-prod-01 as two replicas. It is monitored using Prometheus and Grafana. Alerts are sent to the following Slack channel #prometheus-alerting-prod , #prometheus-alerts, #prometheus-critical.

### Modifying the exim.conf File

The [exim.conf](https://github.com/hmcts/exim-relay/blob/master/exim.conf) file specifies the configuration and behaviour of the mailrelay service in terms of security (hosts that can use the system to route mail, authentication), DNS settings (domain names, routing), protocols and many other settings.  It's created with makefile which collects together a group of related actions into a single build file that when executed compiles or performs some processing to create artifacts.  Read more about makefile here: [makefile tutorial](https://makefiletutorial.com/).  

### Authentication Mechanisms

Client applications use TLS to authenticate to the Mailrelay server to be able to send emails. The server has inbound and outbound certs. Certificates are generated using the [ACME Function App](https://github.com/hmcts/ops-runbooks/tree/master/Certificates)

The following certificates are injected into the Mailrelay container at runtime:

```
dev-mailrelay-platform-hmcts-net
prod-mailrelay-platform-hmcts-net
dev-in.mailrelay.internal.platform.hmcts.net (self signed)
```

## Building and deploying Mailrelay

### Making changes to the exim-relay application

1. Clone the hmcts/exim-relay [repository](https://github.com/hmcts/exim-relay)

2. Make your changes and create a PR for them. Whilst making the Pull Request please ensure that the base repo is hmcts/exim-relay and not luigibk/exim-relay

3. The pipeline will run after making a PR or merging to master and will build an image in the [Azure Container Repository](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-acr-rg/providers/Microsoft.ContainerRegistry/registries/sdshmctspublic/repository)

4. Once all the checks have passed and your PR has been approved, you can merge your changes.

NOTE: The Service connection used for the pipeline is `DTS SS Public Prod`

### Deploying exim-relay

#### Configuring Shared Services Flux

NOTE: these instructions are out of date and need to be updated for flux v2 (looks like image automation is on in dev too):
```
In order to deploy to the latest image to the Dev or Production environment flux needs to know the image it needs to look for.
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)

* Clone the sds-flux-config [repo](https://github.com/hmcts/sds-flux-config)
* Change the tag to the latest tag number in the [patches file](https://github.com/hmcts/sds-flux-config/tree/master/k8s/release/mailrelay/mailrelay/patches)  
* Add and commit changes  
* Review as required
* Merge branch with Master.
* After 5 to 10 minutes check the deployments have been updated on the cluster.
```

## Testing Mailrelay

After making changes to Exim.conf you may need to test that emails are going through according to the authentication mechanism that you have set to be advertised by the host.

### Test StartTLS connection using OpenSSL

Turn user name and password to base 64 

```bash
echo -ne '<password>' | base64
```

Connect to Mailrelay using StartTLS 

```bash
openssl s_client -connect ip:port -starttls smtp
```

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

### Test unauthenticated relay
NOTE: For Mailrelay2, if you try to send an email unauthenticated you will receive a 550 unauthenticated relay response.

Get the IP address of the Mailrelay service and take note of the IP address in the CLUSTER-IP column

```bash
kubectl get svc -n mailrelay mailrelay-exim
```

Spin up a temporary pod in the Kubernetes Cluster

```bash
kubectl run -it --rm --restart=Never -n admin busybox --image=radial/busyboxplus:curl
```

Send email from PCOL to chosen email

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
.
```

### Test TLS connection using SWAKS

```bash
kubectl run my-shell -it --rm --restart=Never -n admin --image=ubuntu --command -- bash
apt update
apt install swaks
apt install telnet
swaks -a -tls -q HELO -s <ip> -au v1test -ap '<password'
```

## Monitoring MailRelay

Pre requisites

* GitHub write access to [Exim-Exporter](https://github.com/hmcts/exim-relay) - Platform Operations team has access
* Azure Devops access to [Exim Exporter Pipeline](https://dev.azure.com/hmcts/Shared%20Services/_build?definitionId=504) - Platform Operations team has access

### Prometheus

* The Prometheus server (Monitoring Namespace) is used to obtain metrics from the exim server and exports them using the Exim-Exporter tool
* The [exim exporter](https://github.com/hmcts/exim_exporter) is used to read and send exim relay metrics to Prometheus server
* The Alert Manager (Monitoring Namespace) takes these metrics and sends it to specified Slack Channels.
* The [Prometheus alerts](https://github.com/hmcts/sds-flux-config/blob/master/k8s/namespaces/monitoring/kube-prometheus-stack/patches/dev/cluster-00/mailrelay-alerts-rules.yaml) for mailrelay can be updated if current alerts needs to be updated

<!--
### Grafana

*more to be added*

-->
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

## Performance Testing

*more to be added*

## Further Links

* <https://www.exim.org/docs.html>

* <https://serverfault.com/>

* <https://alanstorm.com/what-are-prometheus-exporters/>

* <https://prometheus.io/docs/instrumenting/exporters/>
