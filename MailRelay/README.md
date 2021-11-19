
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


Exim Exporter File Structure 
```bash
.
├── Dockerfile
├── LICENSE
├── Makefile
├── README.md
├── Vagrantfile
├── azure_pipeline.yaml
├── debian
│   ├── changelog
│   ├── compat
│   ├── control
│   ├── copyright
│   ├── install
│   ├── prometheus-exim-exporter.default
│   ├── prometheus-exim-exporter.service
│   ├── rules
│   └── source
│       └── format
├── docker-compose.yml
├── go.mod
├── go.sum
├── k8s
│   ├── README
│   ├── pod.yml
│   └── service.yml
├── main.go
├── main_default.go
├── main_systemd.go
├── main_test.go
├── pipeline
│   └── acr_build.yml
└── test
    ├── down.metrics
    ├── mainlog
    ├── paniclog
    ├── rejectlog
    ├── tail.metrics
    ├── up.metrics
    └── update.metrics
```