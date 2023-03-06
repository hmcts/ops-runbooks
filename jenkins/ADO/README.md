# ADO


The following ADO pipeline can be manually run to get the latest available address spaces:
https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=345&_a=summary

## List of the folders in ADO

There are several sets of folders contained in the pipelines. 

- All the ADO folders can be found in ( https://dev.azure.com/hmcts/PlatformOperations/_build?view=folders)

## Guide for runing  the  pipeline

- To Run the  Piplines, click on this link (https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=345&)

- At the top right corner where you can see Run pipleline click on the "Kebab "(that is the three verticle dots)   

- Then click on sttings, at the pipeline settings you will see dailog box which say YAMIL file path select the correct pipeline you want to run on. Then click Run pipeline
  
## Selecting the parameter manuelly 
- At the Branch/tag dailogbox select the branch name then  select plan or 
apply  and click Run.
- If you are running your code for the first time, you must run the plan as  it will indicate whether it will work. 
- In a case where your plan fails, it will indicate where need to be 
fixed within your code.
 
## ADO Environments

These are current environment on the ADO (https://dev.azure.com/hmcts/PlatformOperations/_environments).

- dynatrace-nonprod
- dynatrace-prod
- mgmt
- privatedns-prod
- prod
- sandbox
- sbox