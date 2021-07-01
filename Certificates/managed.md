# Managed certificates

Microsoft documentation for managed certs are [here](https://github.com/hmcts/ops-runbooks/tree/master/Certificates/gandi.md).

#### When to use Managed Certificates
Apps which require one or more of the following will not be suitable for LetsEncrypt and should instead use managed certs:
- need to be passed to a another supplier 
- Frontdoor
- CDN
- App Service