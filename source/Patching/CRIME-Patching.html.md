---
title: Patching CRIME VMs - Operations Guide
weight: 262
last_reviewed_on: 2024-11-15
review_in: 12 months
---
# <%= current_page.data.title %>

The VMs within the CRIME Azure subscriptions, don't have direct access to the internet preventing Azure Update manager from being used. Packages used by the Linux YUM process are held within a CRIME repository and deployed via a Jenkins job. This page describes the steps required to update the CRIME Linux VMs.


### HMCTS Non-Live (Strategic)

This process requires access to the systems in the CRIME non-live environment, so open your VPN link.

[Network Guides](https://hmcts.github.io/ops-runbooks/network/index.html)

# Patch Package Repository
Packages used by Linux the YUM utility are available from the CRIME repository [YUM Packages](https://yum.mdv.cpp.nonlive/pulp/repos/base).

Redhat version 7 updates are held [here](https://yum.mdv.cpp.nonlive/pulp/repos/base/el/7/os/).

Each folder contains updates published during that specific week, with the download happening on the Sunday.
Folder name is Year Month Day. Record the latest numeric folder name for later use in this process.

# Automation Repository
All the scripts to manage the patching process are stored in  

[Github Azure-Policy](https://github.com/hmcts/azure-policy)

Windows VMs - assign.aum_Windows_scan.json
Linux VMs - assign.aum_Windows_scan.json

