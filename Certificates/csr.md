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

Once the csr has been generated, feel free the send the csr and the ssl form to opsconfman@hmcts.net.

### Appendix

SSL Creation Video:
https://cjscommonplatform.sharepoint.com/sites/cftdevops/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2Fcftdevops%2FShared%20Documents%2FSSL%20Creation%20Video%2Emp4&parent=%2Fsites%2Fcftdevops%2FShared%20Documents
