# Top Troubleshooting Commands

Sometimes things don't go perfectly. Pods (your application containers) might get stuck in a Pending state or crash. These are the first commands you should always run to find out what's wrong.

### Lab Objective

Learn the basic kubectl commands to check the status of your nodes and pods, and how to find detailed error messages.

### Procedure

1. Check Your Nodes This command checks if your worker nodes (the VMs) are Ready to accept work. student@bSameple:~$ kubectl get nodes

0. Check System Pods (in kube-system) This checks if the core AWS services (like the Load Balancer and Storage controllers) are running. Use -w to "watch" for live changes.

    `student@bchd:~$` `kubectl get pods -n kube-system -w`

0. Check Application Pods (in clearml) This checks if the ClearML webserver, apiserver, etc., are running.

    `student@bchd:~$` `kubectl get pods -n clearml -w`

0. Describe a Stuck Pod This is the master command. If a pod is stuck in Pending or CrashLoopBackOff, use this to see its "Events" and find the exact error message.

    `student@bchd:~$` `kubectl describe pod <pod-name-goes-here> -n <namespace-goes-here>`
