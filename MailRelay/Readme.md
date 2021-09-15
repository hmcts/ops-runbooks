
Welcome to the Exim Mailrelay Documentation 

Exim-Relay File Structure 
```bash
.
├── Dockerfile
├── LICENSE
├── Makefile
├── README.md
├── azure_pipeline.yaml
├── exim.conf
├── helm
│   └── exim
│       ├── Chart.yaml
│       ├── templates
│       │   ├── NOTES.txt
│       │   ├── _helpers.tpl
│       │   ├── authSecretProviderClass.yaml
│       │   ├── configmap.yaml
│       │   ├── eximExporterService.yaml
│       │   ├── inboundCertificateProviderClass.yaml
│       │   ├── outboundCertificateProviderClass.yaml
│       │   ├── role.yaml
│       │   ├── rolebinding.yaml
│       │   ├── secret.yaml
│       │   ├── service.yaml
│       │   ├── serviceaccount.yaml
│       │   └── statefulsetOrdeployment.yaml
│       └── values.yaml
└── pipeline
    └── acr_build.yml
```


Exim Eporter File Structure 
```bash

```