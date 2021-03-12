# BAIS NSG Rules

This document describes how to add/remove/edit NSG rules for the BAIS enviornments. All rules are managed through automation in the [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure).

## Prerequisites

* GitHub access to [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure)
* Azure DevOps access to [BAIS Pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)
* A CSV file of NSG rules (typically provided by CGI in a DTSPO ticket)
* Member of 'DTS Platform Operations' Azure AD group.

## Steps

1. Any NSG requests should come in the form of a DTSPO ticket with an attached CSV file containing the complete set of rules.

2. Clone [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure) to your local machine.
```bash
git clone https://github.com/hmcts/globalscape-azure-infrastructure
```
3. Create a new branch, typically with the ticket number ID.
```bash
git checkout -b BRANCH-NAME
```
4. Naviagte to terraform/infrastructure/application/stack/02-servers where you will see 4 CSV files containing NSG rules. (2 NLE and 2 Prod)
5. Replace the entire contents of the relevant CSV file with the contents from the DTSPO ticket.
6. Push your new branch
```bash
git push --set-upstream origin BRANCH-NAME
```
7. Create Pull Request and review chnages compared with master.
* Look out for typical formatting issues such as extra spaces or unusual characters. 
* Specifically the '-' in port ranges can often need deleted and retyped depending on how CGI have exported the CSV.

8. In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* 'Run Pipeline'
* Branch/tag: Your new branch name
* Commit: Blank
* Stage to Run: CI
* Location: UK South
* Enviornment: Set as required.
* Advanded Options: Leave as default.

Click **Run**

9. Review pipeline for errors and begin troubleshooting if present.
10. If terraform Plan is successful:
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* 'Run Pipeline'
* Branch/tag: Your new branch name
* Commit: Blank
* Stage to Run: BAIS_Servers
* Location: UK South
* Enviornment: Set as required.
* Advanded Options: Leave as default.

Troubleshoot any pipeline errors.

11. Verify NSG accuratly reflects chnages in CSV file. NSG's are located in: Resource Group: BAU-BAIS_prod_resource_group and BAU-BAIS_stg_resource_group
