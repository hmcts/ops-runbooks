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

### Accessing the Demo Tenant
You can create an App Registration in the `CJS COMMON PLATFORM` Tenant, but to run a more like-for-like environment it's best to create or use an already existing App Reg in the `HMCTS DEMO` Tenant.

To authenticate to the Demo Tenant you can run the command below. If it doesn't work for you, it could mean that a user hasn't been created for you and you need one created. To get a user created you can ask a member of the PlatOps team.

```shell
az login --tenant  hmctsexecdemo.onmicrosoft.com --allow-no-subscriptions
```

Once you've been able to run the above az cli command successfully we can move onto running the operator.

First of all we need to deploy the CRDs and example resources so the Operator knows which Ingresses to watch for and which Reply URLs to manage.

**Note:** Before running the commands below make sure your kubectl context is pointing to your local cluster or a Dev Cluster if you are unable to run a local cluster.

You can use a tool like [KIND](https://sigs.k8s.io/kind) to get a local cluster running.

Once you're happy that you're context is correct you can install the CRDs and resources.

Install CRDs
```shell
 kustomize build config/crd | kubectl apply -f -
```

Create ReplyURLSync and Ingress resources
```shell
kustomize build config/samples | kubectl apply -f -
```

Now you have the necessary resources in place, you should be able to run the Operator.

```shell
go run main.go
```

You should see something similar to below:

```json lines
1.663325436660029e+09   INFO    controller-runtime.metrics      Metrics server is starting to listen    {"addr": ":8080"}
1.6633254366609678e+09  INFO    setup   starting manager
1.663325436661598e+09   INFO    Starting server {"path": "/metrics", "kind": "metrics", "addr": "[::]:8080"}
1.663325436661598e+09   INFO    Starting server {"kind": "health probe", "addr": "[::]:8081"}
1.663325436863172e+09   INFO    Starting EventSource    {"controller": "ingress", "controllerGroup": "networking.k8s.io", "controllerKind": "Ingress", "source": "kind source: *v1.Ingress"}
1.663325436863437e+09   INFO    Starting Controller     {"controller": "ingress", "controllerGroup": "networking.k8s.io", "controllerKind": "Ingress"}
1.663325436863749e+09   INFO    Starting workers        {"controller": "ingress", "controllerGroup": "networking.k8s.io", "controllerKind": "Ingress", "worker count": 1}
1.663325444372884e+09   INFO    Reply URL added {"URL": "https://reply-urls-example-2.local.platform.hmcts.net/oauth-proxy/callback", "object id": "b40e709c-24e0-4e1f-8e79-65268a4c24fe", "ingressClassName": "traefik"}
1.6633254472403562e+09  INFO    Reply URL added {"URL": "https://reply-urls-example-1.local.platform.hmcts.net/oauth-proxy/callback", "object id": "b40e709c-24e0-4e1f-8e79-65268a4c24fe", "ingressClassName": "traefik"}

```

You'll notice that in the logs it states that 2 URLs have been added to the list of Reply URLs. The Operator has picked up the hosts from the Ingresses we created and as they both meet the IngressClassName and Domain filters it has added them to the list. If you're using an already existing Dev cluster there will already by ingresses on that cluster, but they won't match the filters and therefore will not be added to the App Registration's Reply URLs list.

Delete the ingresses from the cluster. 

```shell
kubectl delete -f 'config/samples/ingress-*'
```

You should now see two more lines in the log detailing the removal of the URls as the ingresses no longer exist on the cluster, similar to below:

```json lines
1.6633259693645282e+09  INFO    Reply URLs removed      {"URLs": ["https://reply-urls-example-2.local.platform.hmcts.net/oauth-proxy/callback"], "object id": "b40e709c-24e0-4e1f-8e79-65268a4c24fe", "ingressClassName": "traefik"}
1.663325972135824e+09   INFO    Reply URLs removed      {"URLs": ["https://reply-urls-example-1.local.platform.hmcts.net/oauth-proxy/callback"], "object id": "b40e709c-24e0-4e1f-8e79-65268a4c24fe", "ingressClassName": "traefik"}
```

