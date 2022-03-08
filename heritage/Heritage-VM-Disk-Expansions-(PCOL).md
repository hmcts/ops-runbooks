# Heritage VM Disk Expansions (PCOL)
This document covers the process for expanding the disks for the PCOL VMs and likely other VMs under the heritage umbrella.

## Initial Attempt
Initially an automated approach was tried in the NLE environment for a disk expansion. 
This involved:
1. Modifying the terraform code to increase disk space.
2. Run a terraform plan to ensure only change was disk expansion.
3. Run a terraform apply.

However, soon after this CGI raised an incident. It seemed that the deallocation of the server (during the terraform apply) had caused the drives to mount in the wrong order. This was resolved by a server restart and CGI manually starting the required services for the Oracle DB.

## Working Solution
It was clear that the inital solution wouldn't be viable. From there a strategy was drawn up, tested and successfully carried out in production that didn't involve deallocating the server.

Discovered during NLE testing, it is important CGI are available for disk expansion changes in order to stop/start services to avoid an outage.

Steps:
1. Check disks attached to VM and note the *LUN* of the disk that needs resized.
2. Manually unattach the disk that needs resized via Azure.
3. Manually resize the disk on the portal.
4. Manually attach the disk to the VM on the portal, ensuring the LUN noted in step 1 is used.
5. Retrofit the changes within the terraform code. See [example] (https://github.com/hmcts/oracle-azure-infrastructure/commit/9e99883b6b52274ae8c66ba0b3cb06f721ae311f)
6. Request approval from someone on your team. Once approved merge your pull request.
7. Run a terraform plan to ensure there are no changes.