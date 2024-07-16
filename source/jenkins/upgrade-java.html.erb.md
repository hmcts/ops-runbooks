---
title: Upgrade Java for Jenkins
last_reviewed_on: 2024-07-15
review_in: 12 months
weight: 10
---

# <%= current_page.data.title %>

It is always a good idea to test things in SBOX before doing them in PROD, upgrading Java for Jenkins is no exception.
To upgrade SBOX do the following:

1. 

Then verify that SDS Jenkins is working as expected by running Toffee tests.

Do the same for CFT by running the Plum tests.

If everything is working as expected, you can proceed with the PROD upgrade for SDS.


## Upgrade PROD SDS Jenkins
Firstly merge in the changes to the Docker image that you made earlier. Make note of the tag that is created when you merge it in by checking the build log.

This will involve pointing

1. Bump the Docker image tag for [SDS](https://github.com/hmcts/sds-flux-config/blob/master/apps/jenkins/jenkins/jenkins-controller-version.yaml)
2. Do the same for [PTLSBOX](https://github.com/hmcts/sds-flux-config/blob/master/apps/jenkins/jenkins/ptlsbox/jenkins-controller-version.yaml)
3. After 10 - 15 minutes verify that the upgrade was successful by running [Toffee tests](https://sds-build.hmcts.net/blue/organizations/jenkins/HMCTS_Nightly_Sandbox/sds-toffee-frontend/).

## Upgrade PROD CFT Jenkins
Firstly merge in the changes to the Docker image that you made earlier. Make note of the tag that is created when you merge it in.

This will involve pointing

1. Bump the Docker image tag for [CFT](https://github.com/hmcts/cnp-flux-config/blob/master/apps/jenkins/jenkins/jenkins-controller-version.yaml)
2. Do the same for [PTLSBOX](https://github.com/hmcts/cnp-flux-config/blob/master/apps/jenkins/jenkins/ptlsbox/jenkins-controller-version.yaml)
3. After 10 - 15 minutes verify that the upgrade was successful by running [Toffee tests](https://build.hmcts.net/blue/organizations/jenkins/HMCTS_Nightly_Sandbox/sds-toffee-frontend/).