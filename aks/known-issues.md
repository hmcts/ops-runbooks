# AKS Known Issues

Known issues encountered during AKS cluster update or rebuild

## 1. DaemonSet Failed Scheduling

For a DaemonSet application (e.g. CSI driver, Oneagent or Kured), when applying an update or patch which requires a restart, a pod on a specific node may fail scheduling and blocks the rolling update from proceeding with restarting other pods.  

An error similar to the below may be seen in the cluster events log:  
  
`
Warning  FailedScheduling  20m (x745 over 24m)   default-scheduler  0/72 nodes are available: 23 node(s) didn't match node selector, 43 node(s) didn't have free ports for the requested pod ports, 45 Insufficient cpu.
`

- This happens when there is capacity issue on specific cluster nodes
- DaemonSet rolling update is blocked with the pod stuck in a `Pending` state
- Deleting the pod does not fix issue as pod restarts and goes into same `Pending` state
  
- Run `kubectl get pod <podname> -o yaml | grep nodeName` to identify node where pod scheduling has failed
- Run `kubectl get pods -A | grep <node name>` to list all pods running on node
- Identify and delete or more non-DaemonSet pods to restart on a different node and free up a capacity on the current node  
- If deleted pods are stuck in `Terminating`, use `kubectl delete pod <podname> --grace-period 0 --force` to forcefully delete
- Confirm DaemonSet pod now starts successfully