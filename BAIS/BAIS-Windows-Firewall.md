# BAIS NSG Rules

This document describes how to add/remove/edit Windows Firewall rules for the BAIS servers. All rules are managed through Ansible automation in the [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure).

## Prerequisites

* GitHub access to [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure)
* Azure DevOps access to [BAIS Pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)
* A CSV file containing Windows Firewall rules (typically provided by CGI in a DTSPO ticket)
* Member of 'DTS Platform Operations' Azure AD group.

## Steps

1. Any Windows Firewall requests should come in the form of a DTSPO ticket with an attached CSV file containing the complete set of rules.

2. If needed, clone [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure) to your local machine.
```bash
git clone https://github.com/hmcts/globalscape-azure-infrastructure
```
3. Create a new branch, typically with the ticket number ID.
```bash
git checkout -b BRANCH-NAME
```
4. Naviagte to newansible/files where you will see 4 CSV files containing firewall rules. (2 NLE and 2 Prod)
5. Replace the entire contents of the relevant CSV file with the contents from the DTSPO ticket.
6. Uncomment the Ansible steps which execute the code in: terraform/infrastructure/application/stack/02-servers/30-dmz.tf
Find the following line and remove the starting block comment
Before
```bash
/*resource "null_resource" "ansible-runs" {
```
After
```bash
resource "null_resource" "ansible-runs" {
```
* On the last line remove end of block comment Eg. */

6. Commit your changes and push your new branch
```bash
git push --set-upstream origin BRANCH-NAME
```
7. Create Pull Request and review changes compared with master.
* Look out for typical formatting issues such as extra spaces or unusual characters. 
* Specifically the '-' in port ranges can often need deleted and retyped depending on how CGI have exported the CSV.

8. CI will run automatically across STG after PR is raised. [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 

9. Review pipeline for errors and begin troubleshooting if present.
10. If terraform Plan is successful:
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* 'Run Pipeline'
* Branch/tag: Your new branch name
* Commit: Blank
* Stage to Run: BAIS_Servers
* Location: UK South
* Environment: Set as required.
* Advanced Options: Leave as default.

Click **Run**

Troubleshoot any pipeline errors.

11. Verify NSG accurately reflects changes in CSV file. NSG's are located in: Resource Group: BAU-BAIS_prod_resource_group and BAU-BAIS_stg_resource_group