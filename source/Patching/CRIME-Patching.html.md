---
title: Patching CRIME VMs - Operations Guide
weight: 262
last_reviewed_on: 2024-11-15
review_in: 12 months
---
# <%= current_page.data.title %>

The VMs within the CRIME Azure subscriptions, don't have direct access to the internet preventing Azure Update manager from being used. Packages used by the Linux YUM process are held within a CRIME repository and deployed via a Jenkins job. This page describes the steps required to update the CRIME Linux VMs.


This link is for original but now outdated instructions, which might be helpful, if you encounter a problem.
[Legacy Instructions](https://tools.hmcts.net/confluence/display/EA/Environment+Patching)


# JIRA OS Patching Epics
The monthly patch process begins when an Epic is created, with each environment for patching described in a task. Complex environments like management VMs will be a task, including further sub tasks, for each group of services or areas within the network. 

Management - Non Live Patching
- DMZ
- INT
- SBZ
- IMZ



Search in JIRA for Epics with names like "March OS Patching - All Environments".  The Epic description may include the **yum_repo_patching_tag** to be used within the tasks.

**Management VM Example Tickets**
- [SRE-18441 NONLIVE](https://tools.hmcts.net/jira/browse/SRE-18441)
- [SRE-17423 LIVE](https://tools.hmcts.net/jira/browse/SRE-17423)

## HMCTS Environments
HMCTS CRIME has been split into 2 distinct and isolated **zones**, requiring different user accounts and VPN tunnels to access each zone. The are known as:
- NONLINE
- LIVE

These zones contain the environments.


This confluence page contains details the NONLIVE environments
[Environment management](https://tools.hmcts.net/confluence/display/EA/EA+Environment+management)


### Table of Environments and Zones
|Order| Environment|Arbitration| Zone |
|----|--------------|------------------------|------------|
|1 | Standard Test Environment | STE| NONLIVE |
|2 | Development Environment | Dev| NONLIVE |
|3 | System Integration Testing Environment| SIT| NONLIVE |
|4 | Non-Functional Testing Environment| NFT | NONLIVE |
|5 | Management Development Environment | MDV| NONLIVE |
|6 | Pre Release Production Environment| PRP | LIVE |
|7 | Production Environment| PRD | LIVE |
|8| Management Live Environment| MDV| LIVE |
|9| PRX | PRX | LIVE |

---

# Patching Process
The **yum_repo_patching_tag** value within each environment's YAML configuration file, states which folder of packages should be applied to the VMs within that environment. A Jenkins pipeline can be run, to determine what the packages will do to each VM and report back, without making any changes. If acceptable, a second pipeline is used to deploy the actual patches.

## Patching HMCTS Non-Live (Strategic) Zone
The above table shows that STE, DEV, SIT, NFT and MDV environments are within this zone.

This process requires access to the systems in the CRIME non-live environment, so open your VPN link to the zone.

[Network Guides](https://hmcts.github.io/ops-runbooks/network/index.html)

## Patch Package Repository
Packages used by Linux's YUM utility are available from the CRIME repository [YUM Packages](https://yum.mdv.cpp.nonlive/pulp/repos/base).

Redhat version 7 updates are held [here](https://yum.mdv.cpp.nonlive/pulp/repos/base/el/7/os/).

Each folder contains updates published during that specific week, with the download happening on Sunday. The process is controlled via a Jenkins pipeline called "Pipeline Create New Pulp Tag (automation.ansible). It creates a new folder named Year Month Day (20241103). Confirm a folder name listed, matches what has been provided as the yum_repo_patching_tag in the patching Epic, you are working on.

**NB-** The patches in each folders are current for that calendar week and will contain a roll-up of all the prior weeks. So the weeks don't need to be applied sequentially to each VM.

## Automation Repository
All the scripts to manage the patching process are stored in Gerrit.

- [automation.ansible](https://codereview.mdv.cpp.nonlive/admin/repos/automation.ansible)
- [automation.ansible.paas](https://codereview.mdv.cpp.nonlive/admin/repos/automation.ansible.paas)

Browse to automation.ansible/sp-ansible/group_vars and automation.ansible.pass/sp-ansible/group_vars

Search for "yum_repo_patching_tag" in VS Code or use the consol command 
```
grep -Rns yum_repo_patching_tag 
```

From the list of environments environments displayed, look for your environment.  ie dev, prd, mdv, etc.  Typically the containing folder starts with " 70_environment_"...

Beware of the date displayed.  yum_repo_patching_tag: **20241027**

It should be close to the date you are deploying. If it is out by years, this is the wrong file.  yum_repo_patching_tag: **20190922**

Save the file and commit it with a useful name like

DTSPO-22138 :  set MDV to use yum_repo_patching_tag to 20241103'

Push the completed file/s into the MASTER branch

CLI Example of commands
```
git pull
git push origin HEAD:refs/for/master
git pull
git log
```

### Gerrit Review
Log into the [Gerrit server](https://codereview.mdv.cpp.nonlive/) create and submit a pull request. Posting the URL to Slack [#cpp-code-review](https://moj.enterprise.slack.com/archives/C04JUFUELRM) for review. Merge once approved.


## Jenkins Patching Pipeline
Once the yum_repo_patching_tag has been updated on the configuration files in the repository. The Jenkin pipelines can be used to discover what the new packages will do to the operating systems and then deploy them, if desired.

Open [Jenkins](https://build-paas.mdv.cpp.nonlive/) and search for Ansible - AdHoc (automation.ansible)
Link to [pipeline](https://build-paas.mdv.cpp.nonlive/job/strategic-platform_adhoc_build_ansible.groovy_automation.ansible___ADMIN/)

### Gather Facts
This is like terraform PLAN because the ANSIBLE_PLAYBOOK switch is set to patching.yml

Select build with parameters from Jenkin menu.

- AUTOMATION_ANSIBLE_VERSION = **development**
- ANSIBLE_PLAYBOOK = **patching.yml**
- ANSIBLE_EXTRA_VARS = Can be left blank
- ANSIBLE_LIMIT = VM FQDN use ; to have multiples
- ANSIBLE_TAGS = Can be left blank
- AZURE_SUBSCRIPTION_NAME = Select **sp_mgmt_layer**
- ANSIBLE_INVENTORY = Select **mdv_mgmt**
- SLAVE_LABEL = **ansible2.9.6**

The above example values are for the nonlive management VMs.

<img src=images/Pipeline_Ansible_Gather.png width="800">

Run the pipeline and after about 5 minutes the job will complete.  Review the console logs, to find out, what the patches with do, if they where applied to the sample VM.

```
PLAY RECAP *********************************************************************
MDVDMZJUMPL01.cpp.nonlive  : ok=29   changed=6    unreachable=0    failed=0    skipped=12   rescued=0    ignored=0
```

### Deploy Patches
This is like terraform PLAN because the ANSIBLE_PLAYBOOK switch is set to opsvcs.patching.yml

Select build with parameters from Jenkin menu.

- AUTOMATION_ANSIBLE_VERSION = **development**
- ANSIBLE_PLAYBOOK = **opsvcs.patching.yml**
- ANSIBLE_EXTRA_VARS = errata_fix=true,errata_reboot=false,prepatch_reboot=false
- ANSIBLE_LIMIT = VM FQDN use ; to have multiples
- ANSIBLE_SKIP_TAGS = Can be left blank
- ANSIBLE_TAGS = Can be left blank
- ANSIBLE_ADHOC = -v for extra logging output or leave blank
- AZURE_SUBSCRIPTION_NAME = sp_mgmt_layer
- ANSIBLE_INVENTORY = mdv_mgmt
- SLAVE_LABEL = ansible2.9.6

The above example values are for the nonlive management VMs.

<img src=images/Pipeline_Ansible_Deploy.png width="800">

Run the pipeline and after about 5 minutes the job will complete.  Review the console logs, to find out, what the patches with do, if they where applied to the sample VM.

```
PLAY RECAP *********************************************************************
MDVADMVPNHA201.cpp.nonlive : ok=35   changed=8    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
MDVADMVPNHA202.cpp.nonlive : ok=35   changed=8    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
 
Tuesday 19 November 2024  14:18:02 +0000 (0:00:00.033)       0:01:24.687 ****** 
=============================================================================== 
errata ----------------------------------------------------------------- 71.30s
yum_repo ---------------------------------------------------------------- 9.51s
gather_facts ------------------------------------------------------------ 1.51s
shell ------------------------------------------------------------------- 0.72s
file -------------------------------------------------------------------- 0.69s
include_role ------------------------------------------------------------ 0.32s
debug ------------------------------------------------------------------- 0.14s
reboot ------------------------------------------------------------------ 0.09s
ping -------------------------------------------------------------------- 0.08s
assert ------------------------------------------------------------------ 0.08s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
total ------------------------------------------------------------------ 84.44s
Playbook run took 0 days, 0 hours, 1 minutes, 24 seconds
```

### Confirm Local Results
Use ssh to connect to target VM

sudo grep ^20 /etc/os-patching

<img src=images/ssh_patch_results.png width="800">
