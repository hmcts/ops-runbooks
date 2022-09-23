# reply-urls-operator
An Operator which converts Kubernetes Ingress hosts to valid Reply URLs, updates the App Registration and keeps them in sync.

[Reply URLS Operator - GitHub Repo](https://github.com/hmcts/reply-urls-operator)

## App Registrations currently in use

| Cluster           | App Registration                                                                                                                                                                                                     | Role                                           | Resource / API                                                                                                                                                                                                        |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GitHub Actions    | [reply-urls-operator-demo](https://portal.azure.com/531ff96d-0ae9-462a-8d2d-bec7c0b42082/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/ea8074af-5f20-45df-a3a2-25be693b5c8e/isMSAApp/)    | Acr Push & Contributor (Type: Application)     | [sdshmctspublic](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/sds-acr-rg/providers/Microsoft.ContainerRegistry/registries/sdshmctspublic/overview) |
| Automated Testing | [reply-urls-testing-app](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/2816f198-4c26-48bb-8732-e4ca72926ba7/isMSAApp/)      | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| SDS Sbox          | [reply-urls-operator-test](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/1f26b7c2-a15e-4fa6-a3c7-4c0d95beb2cb/isMSAApp/)    | Application.ReadWrite.All  (Type: Application) | Microsoft Graph API                                                                                                                                                                                                   |
| SDS Demo          | [SDS Oauth Proxy](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/2a3f8b5a-ec0e-470d-b979-fc79d3e74cba/isMSAApp/)             | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| CFT Sbox          | Not created yet                                                                                                                                                                                                      | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |
| CFT Demo          | [Auto Reply URL K8s Operator](https://portal.azure.com/21ae17a1-694c-4005-8e0f-6a0e51c35a5f/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/fbf4cb6e-f09d-4fc4-89fa-b94cb582cb18/isMSAApp/) | Application.ReadWrite.All (Type: Application)  | Microsoft Graph API                                                                                                                                                                                                   |

## Where is the operator deployed to?
The operator is in full use in the demo and AAT environments where it is managing reply urls for an application that is actually in use. It also runs in the sandbox environments where it serves as a place to test changes before pushing changes to the Demo environment. It runs in the admin Namespace.

## Flux configuration
Flux is used to deploy the Reply URLs Operator and keep the resources in sync. The configuration for SDS and CFT can be found below.

[SDS Flux config](https://github.com/hmcts/sds-flux-config/tree/master/apps/admin/reply-urls-operator)

[CFT Flux config](https://github.com/hmcts/cnp-flux-config/tree/master/apps/admin/reply-urls-operator)

## Accessing the Demo Tenant via the az cli
You can create an App Registration in the `CJS COMMON PLATFORM` Tenant for testing, but to run a more like-for-like environment it's best to create or use an already existing App Reg in the `HMCTS DEMO` Tenant.

To authenticate to the Demo Tenant you can run the command below. If it doesn't work for you, it could mean that a user hasn't been created for you and you need one created. To get a user created you can ask a member of the PlatOps team.

```shell
az login --tenant  hmctsexecdemo.onmicrosoft.com --allow-no-subscriptions
```

 