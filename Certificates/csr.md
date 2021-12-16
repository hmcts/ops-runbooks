# Requesting SSL Certificates

Two things are required when requesting new Certs: 
- A completed SSL Form - attached as SSL-Certificate-Request-Form.docx, a blank one has been added so that developers may fill in a new form:
[SSL Certificate Request Form](SSL-Certificate-Request-Form.docx).
This form is only required for new SSLs and is not needed for renewal requests.

- A newly generated CSR request. The CSR's can be generated through a csr.yml file following the guidance in this repo (wildcard certs are generated with a different syntax within the csr.yml file): 

Example Csr.yml files can be found on the openssl-mac-branch branch

MAC Users

https://github.com/hmcts/rdo-ssl-creation/tree/openssl-mac-branch

Linux Users

https://github.com/hmcts/rdo-ssl-creation/tree/master



### Running the CSR generator
Ensure you are logged into the azurecli

> az login

Create a YAML file called csr.yml in the working directory and fill in as per YAML Syntax

Ensure that you have the requirements in the requirements.txt file

> pip install -r requirements.txt

Generate the certificate policy to be uploaded

> ./generate_policy.py

Alternatively run 
> python3 ./generate_policy.py

The vault used to process certificates for renewal is infra-cert-prod 
Note: this can configuring by changing the subscription + vault in the generate_csr script (change variables at the top)

Generate the csr:

> ./generate_csr


The certificate requests will be output to the archive_csr/<date> folder
(wildcard CSRs e.g. *.platform.hmcts.net are generated as wildcard-platform-hmcts-net in the archive folder)


The generated CSRs can also be downloaded again from the key vault under the certificates section should they be lost - click certificate operation, and download CSR.

Once the csr has been generated, feel free to send the csr and the ssl form to opsconfman@hmcts.net.

### Pointing the DNS
  
You will receive an email back asking you to point the DNS, this email will look something like:
"Please add the following DNS record: _EBCEA3AAA604EE544AFE2171A1C19D4A.decree-absolute.apply-divorce.service.gov.uk. 10800 IN CNAME 
CFBF67E5860E17571AFAFDC7492F6BA1.142AB2C674199D39D63BC25392096FBF.38b2baf94efabe47b94f.comodoca.com."
  
There's some changes to make to these instructions before raising a PR:
- Remove the top level domains after the application. So "_EBCEA3AAA604EE544AFE2171A1C19D4A.decree-absolute.apply-divorce.service.gov.uk" from the example would become: `-name: "_EBCEA3AAA604EE544AFE2171A1C19D4A.decree-absolute"` in the yml file.
- TTL: Add a time to live, 300 is the usual TTL used here.
- Add the record: It's important to keep the full stop at the end of the CNAME.
 
The changes made in the PR for this example would look like this: `- name:  "_EBCEA3AAA604EE544AFE2171A1C19D4A.decree-absolute"  
  ttl: 300
  record: "CFBF67E5860E17571AFAFDC7492F6BA1.142AB2C674199D39D63BC25392096FBF.38b2baf94efabe47b94f.comodoca.com."`
  
  
You can then raise a pull request [here](https://github.com/hmcts/azure-public-dns) to add this DNS record to the corresponding yml file, which in this example would be "apply-divorce-service-gov-uk.yml", following the same formatting previous requests have used. After the PR is merged and the build finishes, check the DNS has propagated successfully [here](https://mxtoolbox.com/) before the next step.
  
### Upload certificate to Azure
  
- For this step, clone [rdo-ssl-creation](https://github.com/hmcts/rdo-ssl-creation) repository locally, make sure you're on the correct branch by checking the readme. 
- Convert the .txt cert file to .p7b with this command: `openssl crl2pkcs7 -nocrl -certfile decree-absolute.apply-divorce.service.gov.uk.crt.txt -certfile cert-chain -out decree-absolute.apply-divorce.service.gov.uk.p7b`. Note that Digi2al procured original certs will need the comodoca.crt cert chain in place of cert-chain: found in the makepfx folder.
- Then you can navigate to the Azure Portal and find the relevant certificate in the "infra-cert-prod" vault, in this example it's "decree-absolute-apply-divorce-service-gov-uk". Click Certificate Operation > Merge Signed Request, and then upload the .p7b file created in the previous instruction. After this merge show status as complete, you've successfully renewed/procured the certificate.
  
### Send a certificate to be used by a 3rd Party
  
This step is only required if the certificate is being placed elsewhere or being used by a 3rd Party.
  
- After merging the signed request in the last step, click on the certificate and "Download in PFX/PEM format".
- If you're procuring this cert for a developer in another project that doesn't have access to the key vault, they will need the certs private key. This can be found by running this command: `cat infra-cert-prod-decree-absolute-apply-divorce-service-gov-uk-20200609.pfx | openssl pkcs12 -nodes`.
- If you just need to forward the cert on to the ticket raiser, then you need to add a password to the cert before emailing it. Move the pfx file into the 'makepfx' folder, and change the password in the "pfxpassword.sh" file. Run the command `./pfxpassword.sh infra-cert-prod-decree-absolute-apply-divorce-service-gov-uk-20200609.pfx'.
- You can now send the password-protected cert to whoever requested it. It's best to send the cert in one email, and the password you added to the "pfxpassword.sh" file in another. You can use a site like pwpush.com to do this.
- Add the cert to the relevant key vault: For this example, it would be "cft-apps-prod". Navigate to this key vault and find the cert (decree-absolute-apply-divorce-service-gov-uk), click new version > import > upload the cert.pfx file downloaded earlier and type in the password. You should see a "successfully created" message after this.


### Flip the front door

This is a non-disruptive step and can be done as soon as the new cert has been uploaded.
- Go to Front-Doors in the Azure Portal and choose the relative environment.
- Go to "Front Door Designer" and select the relevant frontend.
- Update the 'secret version' to match the latest one.

  
### Update the CDN profile
 
- Search CDN in Azure portal, navigate to the CDN profile for hmcts-shutter-prod on Azure. find the service, in this case the apply-divorce.service.gov.uk is being renewed, so I will click on the hmcts-shutter-div.
- Find and click on the corect endpoint, after this another set of endpoints will show, click the correct one again.
- Change the secret version to latest, and double check that it matches with the cert updated in "cft-apps-prod".
- Save your changes.
  
  
### Guidance for SDS & PET certificates only
  
For some certs the process is slightly different, example certs include
juror-bureau.justice.gov.uk
reply-jury-summons.service.gov.uk

- Download pfx of the renewed cert from the vault.
- Convert to base 64 `openssl base64 -in ~/Downloads/traefik-jb.pfx -out ~/Downloads/traefik-jdbase64.kl`.
- Reverse engineer  and find new vault - e.g. shared service - ss-vault-prod.
- Restart pods so they pick up the new certs.
  
### Appendix

SSL Creation Video:
https://cjscommonplatform.sharepoint.com/sites/cftdevops/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2Fcftdevops%2FShared%20Documents%2FSSL%20Creation%20Video%2Emp4&parent=%2Fsites%2Fcftdevops%2FShared%20Documents
