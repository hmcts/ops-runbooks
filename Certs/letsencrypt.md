 # How to Create or Renew SSL Certificates

#### Scenario Description:
Platform Operations currently manage all certificates for CFT, SDS, PET and Heritage.

This article describes the process for creating an SSL certificate using LetsEncrypt.

* Note: Apps which need to be passed to a another supplier or require Frontdoor, CDN, or App Service should use managed certs.
#### The requirements for following this process are:
A DTSPO ticket raised in Jira, assigned to the BAU team. 

Instructions for project team users on how to do this can be found [here](http://localhost:4567/information-security/certificate-automation.html#tls-certificates)

## Create a new certificate:

1.	Search for “Function Apps” in the Azure portal
2.	Find the Function App associated with the appropriate subscription (There are different ACME function apps according to the environment where the certificate is to be uploaded)
3.	Click the URL on the Overview page, appending '/add-certificate' to the end if needed
4.	Populate the fields with the information provided in the Jira ticket and click “Submit” (Wildcards are created by using an asterisk as the DNS name)
5.	The cert will now be available in the key vault within the same resource group as the Function App

## Renew an existing certificate: 
The Function App renews certificates automatically. If there is a need to manually renew a certificate, this can be done using the same Function App, appending ‘renew-certificate’ to the url, such as:
https://acmedtssdssbox.azurewebsites.net/renew-certificate. All existing certificates are available from the drop-down menu.