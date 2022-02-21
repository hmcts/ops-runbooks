# AKS Known Issues

Known issues encountered during AKS cluster update or rebuild

## DaemonSet Failed Scheduling

For a DaemonSet application (e.g. CSI driver, Oneagent or Kured), when applying an update or patch which requires a restart, a pod on a specific node may fail scheduling and blocks the rolling update from proceeding with restarting other pods.  

An error similar to the below may be seen in the cluster events log:  
  

- This happens when there is a capacity issue on specific cluster nodes
- DaemonSet rolling update is blocked with the pod stuck in `Pending` state
- Deleting the pod does not fix issue as pod restarts and goes into same `Pending` state
  
- Run `kubectl get pod <podname> -o yaml | grep nodeName` to identify node where pod scheduling has failed
- Run `kubectl get pods -A | grep <node name>` to list all pods running on node
- Identify and delete or more non-DaemonSet pods to restart on a different node and free up a capacity on the current node  
- If deleted pods are stuck in `Terminating` state, use `kubectl delete pod <podname> --grace-period 0 --force` to forcefully delete pod
- Confirm DaemonSet pod now starts successfully