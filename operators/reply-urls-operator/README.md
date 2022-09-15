# reply-urls-operator
An Operator which converts Kubernetes Ingress hosts to valid Reply URLs, updates the App Registration and keeps them in sync.

[GitHub Repo](https://github.com/hmcts/reply-urls-operator)

## Table of Contents
* **[App Registrations currently in use](#App-Registrations-currently-in-use)**<br>
* **[Where is the operator deployed to?](#Where-is-the-operator-deployed-to?)**<br>
* **[Running and testing the operator locally](#Running-and-testing-the-operator-locally)**<br>


## App Registrations currently in use
Most of the App Registrations live in the `HMCTS DEMO` Tenant. The GitHub Workflow   


| Cluster           | App Registration                                                                                                                                                                                                     | Role                                           | Resource / API                                                                                                                                                                                                        |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GitHub Workflows  | [reply-urls-operator-demo](https://portal.azure.com/531ff96d-0ae9-462a-8d2d-bec7c0b42082/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/ea8074af-5f20-45df-a3a2-25be693b5c8e/isMSAApp/)    | Acr Push & Contributor (Type: Application)     | [sdshmctspublic](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-acr-rg/providers/Microsoft.ContainerRegistry/registries/sdshmctspublic/overview) |
| Automated Testing | [reply-urls-testing-app](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/2816f198-4c26-48bb-8732-e4ca72926ba7/isMSAApp/)      | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| SDS Sbox          | [reply-urls-operator-test](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/1f26b7c2-a15e-4fa6-a3c7-4c0d95beb2cb/isMSAApp/)    | Application.ReadWrite.All  (Type: Application) | Microsoft Graph API                                                                                                                                                                                                   |
| SDS Demo          | [SDS Oauth Proxy](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/2a3f8b5a-ec0e-470d-b979-fc79d3e74cba/isMSAApp/)             | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| CFT Sbox          | Not created yet                                                                                                                                                                                                      | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| CFT Demo          | [Auto Reply URL K8s Operator](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/fbf4cb6e-f09d-4fc4-89fa-b94cb582cb18/isMSAApp/) | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |

## Where is the operator deployed to?
The operator is in full use in the demo and AAT environments where it is managing reply urls for an application that is actually in use. It also runs in the sandbox environments where it serves as a place to test changes before pushing changes to the Demo environment. It runs in the admin Namespace.


## Running and testing the operator locally

