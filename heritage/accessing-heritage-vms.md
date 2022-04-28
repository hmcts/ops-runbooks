# Accessing Heritage Virtual Machines

This document details how to gain access to linux heritage VMs, using `POAG-WEB-VM01` as an example.

1. Find and Obtain the v1admin Private Key

Heritage VMs rely on private key authentication for incomming connections as opposed to the azure-based authentication used by most of the project.  We'll need to obtain the private key for the v1admin user. This is a user with sudo privileges that exists on all heritage VMs and is what should be used to log onto and do work on the the machines. Thankfully obtaining the key for this user is fairly easy.

These keys are almost always stored in a key vault within the same subscription as the VMs. In this case, both VMs are in the `DTS-HERITAGE-EXTSVC-PROD` subscription, which only has one key vault: `hmcts-kv-prod-ext`.

Private keys are located under the 'Secrets' tab of the key vault in the Azure Portal. If you don't have secret 'get' or 'list' permissions on the key vault in question, you may need to add an access policy for yourself under the 'Access policies' tab in order to see anything here.

Find a secret named 'v1admin' or similar and keep a hold of it's value, we'll be needing it for later.

2. Gain bastion access for the desired environment.

Details on how to obtain bastion access can be found in [the Bastion documentation on Confluence](https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455). Since `POAG-WEB-VM01` is a production VM, we'll need to request and obtain bastion access for the production environment.

3. SSH into the Bastion Server

```
ssh bastion-prod.platform.hmcts.net
```

4. SSH into the VM

You'll need to provide the private key to obtained in step 1 here. To do this, create a file called 'v1admin.pem' and paste the value in using a text editor of your choice.

```
# Substitute an editor of your choice
vim v1admin.pem
```

If permissions on the private key are too permissive, SSH will refuse to accept it. Here we change the permissions to 400, which will prohibit reading by everyone except your user.

```
chmod 400 v1admin.pem
```

You can then provide the key to SSH using the `-i` flag:

```
# Connect to POAG-WEB-VM01
# Swap the IP out if connecting to a different VM
ssh -i v1admin.pem v1admin@10.224.249.4
```

You should now be connected to the VM. While making the SSH jumps, it can be easy to lose track of what machine you're connected to, especially if doing work across multiple machines. If you ever lose track, you can always check the hostname file to verify what machine you're on:

```
cat /etc/hostname
```
