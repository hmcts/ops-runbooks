# Mailrelay v2

This runbook describes how Mailrelay is configured and deployed and the steps that are necessary to on-board new clients. The Mailrelay configuration can be found in the repo [exim-relay](https://github.com/hmcts/exim-relay).

## Mailrelay Essentials

### How to On-board Clients

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

### What is Mailrelay and What is it used for?

Exim Mail Relay is a Mail Transfer Agent, its main purpose is to receive emails from a Mail User Agent (MUA) and relay the email to other MTAs or a Mail Delivery Agent .

1. Mailrelay AKS deployment

An Exim Mailrelay container is built via Docker and stored in the ACR Azure image repository.  It's based on the featherweight image Alpine as defined in the git repo [Docker Exim Relay Image](https://github.com/hmcts/exim-relay) and is built via an Azure DevOps pipeline.

Exim Mailrelay is currently deployed on AKS in SS-dev-00 / SS-dev-01 / SS-prod-00 / SS-prod-01 as two replicas. It is monitored using Prometheus and Grafana. Alerts are sent to the following Slack channel #prometheus-alerting-prod , #prometheus-alerts, #prometheus-critical.

2. Modifying the exim.conf File

The [exim.conf](https://github.com/hmcts/exim-relay/blob/master/exim.conf) file specifies the configuration and behaviour of the mailrelay service in terms of security (hosts that can use the system to route mail, authentication), DNS settings (domain names, routing), protocols and many other settings.  It's created with makefile which collects together a group of related actions into a single build file that when executed compiles or performs some processing to create artifacts.  Read more about makefile here: [makefile tutorial](https://makefiletutorial.com/).  

3. Authentication Mechanisms

Client applications use TLS to authenticate to the Mailrelay server to be able to send emails. The server has inbound and outbound certs. Certificates are generated using the [ACME Function App](https://github.com/hmcts/ops-runbooks/tree/master/Certificates)

The following certificates are installed in the Docker image which is the source of the mailrelay container:

    dev-mailrelay-platform-hmcts-net
    prod-mailrelay-platform-hmcts-net
    dev-in.mailrelay.internal.platform.hmcts.net (self signed)

4. Client Whitelisting

The IP address of the sending SMTP client must be added to the mailrelay whitelist on the Azure Firewall.  In the case of nonprod, it would be added to the source_ips arrays of mailrelay0 and mailrelay1 here: https://github.com/hmcts/rdo-terraform-hub-dmz/blob/4b317c5ae8f2792380a4e7bfdb49d9f845d1200c/env_tfvars/hub-nonprodi.tfvars#L215

## Deployment

1. Clone Exim-Relay

2. After making changes to the Mailrelay configuration have someone review the pull request.
   * While making the Pull Request please ensure that the base repo is hmcts/ exim-relay and not luigibk/exim-relay

3. Pipeline
   * The pipeline will run after making a PR or merging to master and will build an image in the [Azure Container Repository](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-acr-rg/providers/Microsoft.ContainerRegistry/registries/sdshmctspublic/repository)

     * The Service connection used for the pipeline is `DTS SS Public Prod`

4. Configuring Shared Services Flux

In order to deploy to your latest image to the Dev or Production environment flux needs to know the image it needs to look for.
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)

* Clone the sds-flux-config [repo](https://github.com/hmcts/sds-flux-config)
* change the tag to the latest tag number in the [patches file](https://github.com/hmcts/sds-flux-config/tree/master/k8s/release/mailrelay/mailrelay/patches)  
* Add and Commit changes  
* Review as required
* Merge branch with Master.
* After 5 to 10 minutes check the deployments have been updated on the cluster.

## Testing Mailrelay

After making changes to Exim.conf you may need to test that emails are going through according to the authentication mechanism that you have set to be advertised by the host.

### Test unauthenticated relay

1. Spin up a temporary pod in the Kubernetes Cluster

```bash
kubectl run -it --rm --restart=Never -n admin busybox --image=radial/busyboxplus:curl
```

2. Get the IP address

```bash
Kubectl get svc -n <namespace>
```

3. Send email from pcol to chosen email

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

* Note - For dev clusters, unauthenticated relay should be turned off and you should receive a 550 unauthenticated relay response

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
