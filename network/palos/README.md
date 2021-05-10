# Palo Alto

This guide aims to give you an introduction to the HMCTS Palo Alto firewalls setup and provide you with some tips on how to troubleshoot common errors. 

### Further reading/watching 
- [GitHub Repository](https://github.com/hmcts/rdo-terraform-hub-dmz)
- [Hub DMZ documentation](https://tools.hmcts.net/confluence/display/RD/HUB-DMZ)
- [KT videos](https://cjscommonplatform.sharepoint.com/sites/DTSPlatformOperationsTeam/Shared%20Documents/Transition%20to%20new%20supplier/Videos/Hub,%20DMZ,%20VPN%20&%20Networks.mp4)

## [General](guide.md)

- Testing changes - target ukwest 
- Common errors
- Workflow for making a change
- ukw / uks setup
- Raise a change for prod
- Running terraform locally - pipeline out of action, make sure you communicate
- Pipeline tests (i.e. someone broke plum and the hub build doesn't work)

## [Connecting to a Palo Alto firewall](general.md)

- How to connect to palo login in prod vs nonprod
- How to connect over ssh - advance use case, got a custom shell, see logs, tcp dump etc 

## [Troubleshooting issues](troubleshooting.md)