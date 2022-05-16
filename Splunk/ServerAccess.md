# Splunk Server Access

This document describes how to get access to the Splunk servers for operational support.

## Prerequisites

* HMCTS email account
* Connected to the VPN
* Member of 'DTS Platform Operations' or 'dcd_team_secops_v2' Azure AD group
* SSH Config for HMCTS Bastions

## Connecting to Splunk servers

1. Connect to the [HMCTS VPN](https://portal.platform.hmcts.net).

2. Request JIT access to HMCTS Bastion Server - https://myaccess.microsoft.com/
```text
 SecOps Sandbox Bastion Server Access OR SecOps Production Bastion Server Access
```
4. SSH onto bastion secops server
See here for a steps on how to do this: [HMCTS Confluence bastion access](https://tools.hmcts.net/confluence/display/RD/Bastion)

5. SSH onto required Splunk server via the SecOps bastion you're now logged into. You should be be able to login using your Azure Active Directory account details (assuming you've been added to the JIT groups above).
**Follow the instructions output from the SSH command**

## Additional notes
### Access package configuration
The access packages 'SecOps Sandbox Bastion Server Access' and 'SecOps Production Bastion Server Access' can be found in the Azure Portal under 'Identity Governance', any updates and amendments to this should be made here.
### VM authentication
User access to splunk VMs are provided by Azure Active Directory (AAD) login, which is provisioned onto the VMs during deployment via the VM extension 'AADLoginForLinux'; this saves us having to retrieve and exchange SSH keys.