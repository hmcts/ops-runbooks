# BAIS NSG Rules

This document describes how to add/remove/edit NSG rules for the BAIS environments. All rules are managed through automation in the [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure).

Rules should be adjusted by the project team on a self-service basis.

## Prerequisites

* GitHub write access to [Globalscape Repo](https://github.com/hmcts/globalscape-azure-infrastructure)
* Azure DevOps access to [BAIS Pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432)

## Process

A PR for changes to the BAIS NSG rules should be raised by the person or team requesting the change. The Platform Operations will review the PR and provide approval, followed by executing the pipeline on behalf of the requester.
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
3. Navigate to terraform/infrastructure/application/stack/02-servers where you will see 4 CSV files containing NSG rules. (2 NLE and 2 Prod)
4. Modify the CSV file for the required environment looking to existing rules for formatting guidance. Note: removing rules from the CSV will remove them from Azure.
5. Push your new branch
```bash
git push --set-upstream origin BRANCH-NAME
```
6. Create a Pull Request and review changes compared with master.
* Look out for typical formatting issues such as extra spaces or unusual characters. 
* Specifically, the '-' in port ranges can often need deleted and retyped depending on how rules have been exported from a CSV.

7. Raise a BAU ticket with the PlatOps team requesting PR approval and execution.

## Platform Operations Steps

8. Review PR and provide approval as appropriate, see step 6 for common formatting issues.
Check for failed tests in the terraform plan that was triggered following the PR.

9. Terraform Apply
In [Azure DevOps](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=432) 
* 'Run Pipeline'
* Branch/tag: Your new branch name
* Commit: Blank
* Stage to Run: BAIS_Servers
* Location: UK South
* Environment: Set as required.
* Advanced Options: Leave as default.

Click **Run**

10. Review pipeline for errors and begin troubleshooting if present.

11. Verify NSG accurately reflects CSV file change in from PR. NSG's are located in: Resource Group: BAU-BAIS_prod_resource_group and BAU-BAIS_stg_resource_group.

11. Merge branch with Master.