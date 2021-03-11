# BAIS Server Access

This document describes how to get access to the BAIS servers for operational support.

## Prerequisites

You must be in the following groups:

* HMCTS email account
* Connected to the VPN
* Member of 'DTS Platform Operations' Azure AD group
* SSH Config for HMCTS Bastions

You can add yourself to any groups via the [devops-azure-aad GitHub repo](https://github.com/hmcts/devops-azure-ad/blob/master/users/prod_users.yml).

## Connecting to services

1. Connect to the [HMCTS VPN](https://portal.platform.hmcts.net).

2. Download BAIS Bastion Private Key from KeyVault:

```bash
az keyvault secret download -f ~/.ssh/bais-bastion-key --vault-name ss-vault-prod --name bau-bais-prod-ssh-private-key 
chmod 600 ~/.ssh/bais-bastion-key
```

3. Request JIT access to HMCTS Bastion Server - https://myaccess.microsoft.com/
```text
 Production Bastion Server Access OR Non-Production Bastion Server
```

4. SSH Config:
```ssh-config
NLE

    #BAIS NLE
    Host bais-nle
    Hostname 10.225.251.10
    ProxyJump REPLACE with host entry of HMCTS bastion.
    User ubuntu
    ForwardAgent yes
    IdentitiesOnly yes
    IdentityFile ~/.ssh/bais-bastion-key
```
```bash
Production

    #BAIS Prod
    Host bais-prod
    Hostname 10.224.251.10
    ProxyJump REPLACE with host entry of HMCTS bastion.
    User ubuntu
    ForwardAgent yes
    IdentitiesOnly yes
    IdentityFile ~/.ssh/bais-bastion-key
```

5. Create an SSH tunnel to BAIS EFT01
```bash
ssh -L33390:10.225.251.135:3389 bais-nle
# OR 
ssh -L33391:10.225.251.135:3389 bais-prod
```

6. Open an RDP window and remote to localhost:33390 for NLE or localhost:33391 for Production. An HMCTS account will work here as these machines have been domain joined.
