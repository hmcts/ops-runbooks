# AKS Scripts
-------------


## Check Minimum Chart Versions
This script was created to compare chart versions being used in the cluster with a minimum chart requirement. This will be a useful tool for checking all teams have updated before rebuilding a cluster with a necessary change added to a given chart version.

### Pre-requisites

- [`jq`](https://stedolan.github.io/jq/download/). 
- [`azure-cli`](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Connect to one of the AKS clusters](https://hmcts.github.io/ways-of-working/troubleshooting/) before running the script.

### Running the script
Make sure to run `az login`, to run the script, clone this repository and switch into the `aks` directory, run `./checkMinimumChartVersions.sh`. The script runs against your current kubectl context, and generates output based on applications running in the cluster.

------------