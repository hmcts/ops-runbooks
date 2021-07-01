# Managed certificates

Microsoft documentation for managed certs are [here](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-custom-domain-https#option-1-default-use-a-certificate-managed-by-front-door).

#### When to use Managed Certificates
Apps which require one or more of the following will not be suitable for LetsEncrypt and should instead use managed certs:
- need to be passed to a another supplier 
- Frontdoor
- CDN
- App Service