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
All the scripts to manage the patching process are stored in Gerrit.

[automation.ansible](https://codereview.mdv.cpp.nonlive/admin/repos/automation.ansible)

Browse to automation.ansible/sp-ansible/group_vars

Search for "yum_repo_patching_tag" in VS Code or use the consol command 
```
grep -Rns yum_repo_patching_tag 
```

From the list of environments environments displayed, look for your environment.  ie dev, prd, mdv, etc.

Beware of the date displayed.  yum_repo_patching_tag: **20241027**

It should be close to the date you are deploying. If it is out by years, this is the wrong file.  yum_repo_patching_tag: **20190922**

Save the file and commit it with a useful name like

DTSPO-22138 :  set MDV to use yum_repo_patching_tag to 20241103'