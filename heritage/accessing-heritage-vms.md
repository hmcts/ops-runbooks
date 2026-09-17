# Accessing Heritage Virtual Machines

This document details how to gain access to linux heritage VMs, using `POAG-WEB-VM01` as an example.

1. Gain bastion access for the desired environment.

Details on how to obtain bastion access can be found in [the Bastion documentation on Confluence](https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455). Since `POAG-WEB-VM01` is a production VM, we'll need to request and obtain bastion access for the production environment.

2. SSH into the Bastion Server

```
ssh bastion-prod.platform.hmcts.net
```

4. SSH into the VM

You'll need to provide the password for your HMCTS account here.

```
# Connect to POAG-WEB-VM01
# Swap the IP out if connecting to a different VM
ssh 10.224.249.4
```

You should now be connected to the VM. While making the SSH jumps, it can be easy to lose track of what machine you're connected to, especially if doing work across multiple machines. If you ever lose track, you can always check the hostname file to verify what machine you're on:

```
cat /etc/hostname
```
