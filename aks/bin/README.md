# AKS Scripts
-------------


## Check Minimum Chart Versions
This script was created to compare chart versions being used in the cluster with a minimum chart requirement. This will be a useful tool for checking all teams have updated before rebuilding a cluster with a necessary change added to a given chart version.

### Pre-requisites

Please ensure that you have jq installed in order for this to be run. This can be installed by running the command `brew install jq`. Please ensure you are connected to one of the AKS clusters.

### Running the script
Make sure to run `az login`, to run the script, clone this repository and switch into the `aks` directory, run `./checkMinimumChartVersions.sh`. The script runs against your current kubectl context, and generates output based on applications running in the cluster.

------------