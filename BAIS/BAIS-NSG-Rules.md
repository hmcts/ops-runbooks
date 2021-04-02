# BAIS NSG Rules

This document describes how to add/remove/edit NSG rules for the BAIS enviornments. All rules are managed through automation in the [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure).

## Prerequisites

* GitHub access to [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure)
* Azure DevOps access to [BAIS Pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)
* Member of 'DTS Platform Operations' Azure AD group.

## Process

A PR for changes to the BAIS NSG rules should be raised by the person or team requesting the change. The Platform Operations will review the PR and provide approval, follwed by executing the pipeline on behalf of the requester.
See steps 1 to 7 for details on raising a PR.

## Self-Service Steps

1. Clone [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure) to your local machine.
```bash
git clone https://github.com/hmcts/globalscape-azure-infrastructure
```
2. Create a new branch, typically with a JIRA ticket number.
```bash
git checkout -b BRANCH-NAME
```
3. Naviagte to terraform/infrastructure/application/stack/02-servers where you will see 4 CSV files containing NSG rules. (2 NLE and 2 Prod)
4. Modify the CSV file for the required environment looking to exisitng rules for formatting guidance. Note: removing rules from the CSV will remove them from Azure.
5. Push your new branch
```bash
git push --set-upstream origin BRANCH-NAME
```
6. Create Pull Request and review changes compared with master.
* Look out for typical formatting issues such as extra spaces or unusual characters. 
* Specifically the '-' in port ranges can often need deleted and retyped depending on how rules have been exported from a CSV.

## Platform Operations Steps

7. Review PR and provide approval as appropriate, see step 6 for common formatting issues.
Check for failed tests in the terraform plan that was triggered following the PR.

8. Terraform Apply
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* 'Run Pipeline'
* Branch/tag: Your new branch name
* Commit: Blank
* Stage to Run: BAIS_Servers
* Location: UK South
* Enviornment: Set as required.
* Advanded Options: Leave as default.

Click **Run**

9. Review pipeline for errors and begin troubleshooting if present.

10. Verify NSG accuratly reflects CSV file chnage in from PR. NSG's are located in: Resource Group: BAU-BAIS_prod_resource_group and BAU-BAIS_stg_resource_group
