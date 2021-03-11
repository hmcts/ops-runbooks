# BAIS Server Access

This document describes how to get access to the BAIS servers for operational support.

## Prerequisites

You must be in the following groups:

* HMCTS email account
* Connected to the VPN
* Member of 'DTS Platform Operations' Azure AD group
* SSH Config for HMCTS Bastions

You can add yourself to any groups via the [devops-azure-aad GitHub repo](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml).

## Connecting to BAIS servers

1. Connect to the [HMCTS VPN](https://portal.platform.hmcts.net).

2. Request JIT access to HMCTS Bastion Server - https://myaccess.microsoft.com/
```text
 Production Bastion Server Access OR Non-Production Bastion Server
```
4. Start an SSH tunnel through the HMCTS Bastion to BAIS EFT01
```bash
ssh -L33390:10.225.251.135:3389 nonprodbastion
# OR 
ssh -L33391:10.224.251.135:3389 prodbastion
```
**Follow command line instructions**

5. Open an RDP window and remote to localhost:33390 for NLE or localhost:33391 for Production. An HMCTS account will work here as these machines have been domain joined.

**Note:** You may need to rest your password if you have never logged into the HMCTS managed domain before. This is because the domain was created after the majority of our accounts.
