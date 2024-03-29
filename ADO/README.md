# Azure Boards 

These are agile tools that help us plan, and track any unit of  our works in software project. (https://dev.azure.com/hmcts/PlatformOperations/_workitems/recentlyupdated/)


##  ADO Projects

- ADO has Projects, which contain Boards and Pipelines within Platform Operations project but Boards, Repos, Pipelines, Test Plans and Artifacts within the DLRM project.

 - In the context of ADO, the Platform Operations and DLRM projects have different configurations and structures within ADO. Specifically, the Platform Operations project appears to have Boards and Pipelines as its main components. In contrast, the DLRM project has a more extensive set of components, including Boards, Repos, Pipelines, Test Plans, and Artifacts.(https://dev.azure.com/hmcts/DLRM/_testManagement/mine)

 - Azure DevOps pipelines runs using agents and service connections to execute the tasks defined in the pipeline. The agents and service connections provide a way for the pipeline to interact with external systems, such as cloud services, databases, or other external tools.

- All the ADO folders can be found in ( https://dev.azure.com/hmcts/PlatformOperations/_build?view=folders)

## Guide for running  the  pipeline

- To Run the  Pipelines, click on this link (https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=345&)

- At the top right corner where you can see Run pipeline click on the "Kebab "(that is the three vertical dots)   

- Then click on settings, at the pipeline settings you will see dialog box which say YAML file path select the correct pipeline you want to run on. Then click Run pipeline
  
## Selecting 

- At the Branch/tag dialog box select the branch name then  select plan or 
apply  and click Run.
- If you are running your code for the first time, you must run the plan as  it will indicate whether it will work. 
- In a case where your plan fails, it will indicate where need to be 
fixed within your code.
 
## Configuration

All pipelines  are 100% managed as code, you should never 
have to edit any configuration manually.
 
## ADO Environments

These are current environment on the ADO (https://dev.azure.com/hmcts/PlatformOperations/_environments)

- dynatrace-nonprod
- dynatrace-prod
- mgmt
- privatedns-prod
- prod
- sandbox
- sbox
  

## Guides

- [Troubleshooting links pipeline runs]( https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/troubleshooting?view=azure-devops)
  
- [Review logs to diagnose pipeline issues](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops)