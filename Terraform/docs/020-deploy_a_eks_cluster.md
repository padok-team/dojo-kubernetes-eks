# EKS Cluster

## Configure

Your cluster will be deployed through the eks layer.

Customize your configuration, based on examples: node group, etc

## ⚠️ ⚠️ ⚠️  Default admin on EKS ⚠️ ⚠️ ⚠️

The default EKS admin will be set regarding the user or the role used to create the cluster.

Don't use a user to deploy EKS, use a role. Otherwise, only the user who create the cluster will be able to connect to the cluster.

To set additional user and role, use the `manage_aws_auth_configmap` and `aws_auth_roles` options.

```
inputs = {
  context = {
    manage_aws_auth_configmap = true
    aws_auth_roles =  [
        {
            rolearn  = "arn:aws:iam::66666666666:role/role1"
            username = "role1"
            groups   = ["system:masters"]
        },
    ]
```

## Deploy

Go to the environnement:

```bash
cd layers/eks/dev
terragrunt init
terragrunt apply
```

## Connect To EKS

After the apply, you will find a use helper that tell you how to connect to your EKS cluster with SSM.

After the last command, the tunnel is opened and your shell will look like this:

```bash

Starting session with SessionId: guillaumel-054b0a9c778e31733
Port 10443 opened for sessionId guillaumel-054b0a9c778e31733.
Waiting for connections...

```

Now, open a new shell and use `kubectl` to manage your cluster:

```bash
kubectl get pods -A

NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-2rg25             1/1     Running   0          21m
kube-system   coredns-56bddd599c-g4rc8   0/1     Pending   0          30m
kube-system   coredns-56bddd599c-jbgw6   0/1     Pending   0          30m
kube-system   kube-proxy-xwtxv           1/1     Running   0          21m

kubectl get nodes
NAME                                         STATUS   ROLES    AGE   VERSION
ip-10-0-135-114.eu-west-3.compute.internal   Ready    <none>   21m   v1.22.12-eks-ba74326
```

Note that in this example, since the node type used is small and the setting specifies only 1 node in the node group, there isn't enough resources to deploy coredns. Adjust the setting regarding your needs.

### Reminder to get the output later

```
cd layers/eks/env
tg output -raw how_to
```
