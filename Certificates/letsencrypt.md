# How to Create or Renew SSL Certificates using Let’s Encrypt

#### Scenario Description
The Platform Operations team currently manages certificates for:
- CFT
- SDS
- PET
- Heritage

Consumer documentation can be found on [the HMCTS way](https://hmcts.github.io/information-security/certificate-automation.html#tls-certificates).

## Create a new certificate

1.	Search for “Function Apps” in the Azure portal
2.	Find the Function App associated with the appropriate subscription, the name format is `acme<subscription-name>` sharedservices is replaced with sds because of length limits, (There are different ACME function apps according to the environment where the certificate is to be uploaded)
3.	Click the URL on the Overview page, appending '/add-certificate' to the end if needed
4.	Populate the fields with the information provided in the Jira ticket and click “Submit” (Wildcards are creted by using an asterisk as the DNS name)
5.	The cert will now be available in the key vault within the same resource group as the Function App

## Renew an existing certificate
The Function App renews certificates automatically. If there is a need to manually renew a certificate, this can be done using the same Function App, appending ‘renew-certificate’ to the url, such as:
https://acmedtssdssbox.azurewebsites.net/renew-certificate. All existing certificates are available from the drop-down menu.