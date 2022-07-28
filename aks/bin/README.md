# Script to check chart versions being used in a cluster

This script was created for [DTSPO-9306](https://tools.hmcts.net/jira/browse/DTSPO-9306) to compare chart versions being used in the cluster with a minimum chart requirement. This will be a useful tool for checking all teams have updated before rebuilding a cluster with a necessary change added to a given chart version.

## Pre-requisites

Please ensure that you have jq installed in order for this to be run. This can be installed by running the command `brew install jq`. Please ensure you are connected to one of the AKS clusters.

## Description

To run the script, clone this repository and switch into `aks/bin` directory, then run `./checkMinimumChartVersions.sh`. You may need to give executable permissions first with `chmod +x checkMinimumVersions.sh` and make sure you've ran `az login` too. The script runs against your current kubectl context, and generates output based on applications running in the cluster.