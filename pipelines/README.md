# Running Test Jobs
A set of Docker images and Kubernetes YAMLs to test out running KnowEnG jobs
under Kubernetes.

# Production Cluster Setup
1. Run a [Kubernetes cluster on AWS](https://github.com/aws-samples/aws-workshop-for-kubernetes)
2. Set up [cluster-monitoring](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/201-cluster-monitoring)
3. Create multiple auto-scaling groups via `kops create ig --subnet <subnets>`
4. Set up [cluster-autoscaling](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/205-cluster-autoscaling) to watch [multiple ASGs](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-multi-asg.yaml#L139-L141)
5. [Create an EFS volume](https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html) in the same region/vpc/security groups as your Kubernetes worker nodes
6. Set up the [EFS provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs#getting-started)

# Prerequisites
* You will need to install [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your local machine
* You will need to populate `~/.kube/config` on your local machine (ask your cluster admin to provide the file)
* You will need to clone this repo to your local machine, if you haven't already done so

You should now be able to use `kubectl` to access the AWS cluster from your
local machine:
```bash
$ kubectl get nodes -l kops.k8s.io/instancegroup=nodes
NAME                             STATUS    ROLES     AGE       VERSION
ip-172-20-120-213.ec2.internal   Ready     node      2h        v1.8.6
ip-172-20-211-99.ec2.internal    Ready     node      1h        v1.8.6

$ kubectl get nodes -l kops.k8s.io/instancegroup=mediumjobs
NAME                             STATUS    ROLES     AGE       VERSION
ip-172-20-202-174.ec2.internal   Ready     node      37m       v1.8.6

$ kubectl get nodes -l kops.k8s.io/instancegroup=longjobs
NAME                             STATUS    ROLES     AGE       VERSION
ip-172-20-97-49.ec2.internal     Ready     node      4h        v1.8.6
```

NOTE 1: worker nodes are currently divided into 3 instance groups:
* `nodes`: 2 always-running t2.medium instances
* `mediumjobs`: 1 - 3 auto-scaling m4.large instances
* `longjobs`: 1 - 3 auto-scaling m4.xlarge instances

NOTE 2: Once the next version of the Cluster Autoscaler is released, we should
be able to scale these groups down to zero to save even more on our AWS budget.

## Cluster Components
You can check the logs of the EFS provisioner by running the following:
```bash
$ kubectl logs -f deploy/efs-provisioner --namespace=default
```

NOTE: The EFS Provisioner **must** run in the same namespace as the containers
to which you plan to mount the EFS shared volume.

You can check the logs of the Cluster AutoScaler with the following command:
```bash
$ kubectl logs -f deploy/cluster-autoscaler --namespace=kube-system
```

The Cluster Autoscaler polls every 10 seconds to determine if more nodes are
needed or if there are any underutilized nodes (for 10+ minutes) running that
can be safely removed.

## Monitoring Your Cluster via Web UI
To access cluster monitoring web interfaces, you can run `kubectl proxy` on your local machine:
```bash
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

This effectively uses your kubectl access token to tunnel your localhost port
8001 to the cluster's unexposed admin monitoring services.

Your local machine's browser should now resolve the following link(s):
* Kubernetes Dashboard: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default
* Grafana: http://localhost:8001/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy/?orgId=1
* Kibana (Coming Soon): https://console.aws.amazon.com/es/home?#kubernetes-logs:dashboard

## Monitoring Your Cluster via CLI
You can see what's running with:
```bash
$ kubectl get all --all-namespaces
```

You can view resource utilization with:
```bash
$ kubectl top nodes
NAME                            CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%   
ip-172-20-121-42.ec2.internal   36m          0%        815Mi           5%        
ip-172-20-41-90.ec2.internal    103m         10%       1465Mi          39%       
ip-172-20-56-70.ec2.internal    42m          1%        927Mi           5%
```

# Running a Job
Run a benchmark Gene Prioritization job that mounts shared storage from EFS:
```bash
$ kubectl apply -f gp-benchmark-efs.job.yaml
```

To run with local storage (no EFS), you can run:
```bash
$ kubectl apply -f gp-benchmark.job.yaml
```

Another YAML/image allows you to substitute in each parameter to the pipeline image:
```bash
$ vi gp.job.yaml
$ kubectl apply -f gp.job.yaml
```

NOTE 1: This uses an unofficial/out-of-date Docker image that can be updated if 
requested.

NOTE 2: To execute on a particular instance group, you can pass a `nodeSelector` as 
part of your YAML spec:
```yaml
     ...
  template:
    metadata:
      name: gp-medium
    spec:
      nodeSelector:
        kops.k8s.io/instancegroup: mediumjobs
      containers:
      - name: gene-prioritization
        image: knowengdev/gene_prioritization_pipeline:07_26_2017
     ...
```

## View Running Jobs
Initially this creates 2 gp-benchmark pods, each running a single container.
```bash
$ kubectl get jobs,pods -o wide
NAME           DESIRED   SUCCESSFUL   AGE       CONTAINERS            IMAGES                                    SELECTOR
gp-benchmark   <none>    0            1m        gene-prioritization   bodom0015/gene-prioritization:benchmark   controller-uid=88866be6-182a-11e8-9975-12ab15281942

NAME                              READY     STATUS    RESTARTS   AGE       IP           NODE
efs-provisioner-6f9b99757-pxr7b   1/1       Running   0          4m        100.96.8.3   ip-172-20-121-42.ec2.internal
gp-benchmark-26d8r                1/1       Running   0          53s       100.96.8.4   ip-172-20-121-42.ec2.internal
gp-benchmark-z4q58                1/1       Running   0          53s       100.96.7.9   ip-172-20-56-70.ec2.internal
```

NOTE: In order to show `Completed` jobs, you will need to pass `-a` to
`kubectl get pods`.

## Scaling Out
```bash
$ kubectl scale jobs/gp-benchmark --replicas=16
```

You should now see more container replicas in the output from `kubectl get pods`:
```bash
$ kubectl get pods -o wide
NAME                              READY     STATUS    RESTARTS   AGE       IP           NODE
efs-provisioner-6f9b99757-pxr7b   1/1       Running   0          6m        100.96.8.3   ip-172-20-121-42.ec2.internal
gp-benchmark-26d8r                1/1       Running   0          2m        100.96.8.4   ip-172-20-121-42.ec2.internal
gp-benchmark-6qhh4                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-7c42t                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-bfljm                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-clnn2                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-cnz5f                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-czt4q                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-jcstw                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-kv2hp                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-lw282                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-r58g8                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-shcvh                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-st7rq                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-szstx                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-xxktb                0/1       Pending   0          39s       <none>       <none>
gp-benchmark-z4q58                1/1       Running   0          2m        100.96.7.9   ip-172-20-56-70.ec2.internal
```

You should see in the cluster-autoscaler logs that pods are now unschedulable,
and a quick count will be performed estimating the amount of extra nodes that 
need to be created:
```bash
$ kubectl logs -f deploy/cluster-autoscaler --namespace=kube-system
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
I0222 23:47:38.994066       1 static_autoscaler.go:213] Filtering out schedulables
I0222 23:47:38.995022       1 static_autoscaler.go:221] No schedulable pods
I0222 23:47:38.995071       1 scale_up.go:50] Pod default/gp-benchmark-bfljm is unschedulable
I0222 23:47:38.995098       1 scale_up.go:50] Pod default/gp-benchmark-xxktb is unschedulable
I0222 23:47:38.995121       1 scale_up.go:50] Pod default/gp-benchmark-czt4q is unschedulable
I0222 23:47:38.995141       1 scale_up.go:50] Pod default/gp-benchmark-6qhh4 is unschedulable
I0222 23:47:38.995183       1 scale_up.go:50] Pod default/gp-benchmark-shcvh is unschedulable
I0222 23:47:38.995205       1 scale_up.go:50] Pod default/gp-benchmark-kv2hp is unschedulable
I0222 23:47:38.995226       1 scale_up.go:50] Pod default/gp-benchmark-lw282 is unschedulable
I0222 23:47:38.995250       1 scale_up.go:50] Pod default/gp-benchmark-st7rq is unschedulable
I0222 23:47:38.995277       1 scale_up.go:50] Pod default/gp-benchmark-szstx is unschedulable
I0222 23:47:38.995311       1 scale_up.go:50] Pod default/gp-benchmark-clnn2 is unschedulable
I0222 23:47:38.995355       1 scale_up.go:50] Pod default/gp-benchmark-r58g8 is unschedulable
I0222 23:47:38.995379       1 scale_up.go:50] Pod default/gp-benchmark-cnz5f is unschedulable
I0222 23:47:38.995399       1 scale_up.go:50] Pod default/gp-benchmark-7c42t is unschedulable
I0222 23:47:38.995420       1 scale_up.go:50] Pod default/gp-benchmark-jcstw is unschedulable
I0222 23:47:39.040062       1 scale_up.go:71] Upcoming 8 nodes
I0222 23:47:39.125852       1 scale_up.go:91] Skipping node group nodes.knowkube.cluster.k8s.local - max size reached
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
```

A few minutes later, these nodes should appear in the EC2
Management Console as well as in the output of `kubectl get nodes`:
```bash
$ kubectl get nodes
NAME                             STATUS    ROLES     AGE       VERSION
ip-172-20-121-42.ec2.internal    Ready     node      15m       v1.8.6
ip-172-20-140-4.ec2.internal     Ready     node      56s       v1.8.6
ip-172-20-151-7.ec2.internal     Ready     node      44s       v1.8.6
ip-172-20-181-222.ec2.internal   Ready     node      56s       v1.8.6
ip-172-20-205-190.ec2.internal   Ready     node      21s       v1.8.6
ip-172-20-221-153.ec2.internal   Ready     node      25s       v1.8.6
ip-172-20-41-90.ec2.internal     Ready     master    1h        v1.8.6
ip-172-20-56-70.ec2.internal     Ready     node      22m       v1.8.6
ip-172-20-82-118.ec2.internal    Ready     node      1m        v1.8.6
```

And once the nodes are `Ready`, we see that more of our jobs can run simultaneously:
```bash
$ kubectl get pods -o wide
NAME                              READY     STATUS    RESTARTS   AGE       IP            NODE
efs-provisioner-6f9b99757-pxr7b   1/1       Running   0          10m       100.96.8.3    ip-172-20-121-42.ec2.internal
gp-benchmark-bfljm                1/1       Running   0          4m        100.96.13.2   ip-172-20-221-153.ec2.internal
gp-benchmark-cnz5f                1/1       Running   0          4m        100.96.8.7    ip-172-20-121-42.ec2.internal
gp-benchmark-czt4q                1/1       Running   0          4m        100.96.15.2   ip-172-20-174-227.ec2.internal
gp-benchmark-jcstw                1/1       Running   0          4m        100.96.7.12   ip-172-20-56-70.ec2.internal
gp-benchmark-shcvh                1/1       Running   0          4m        100.96.12.2   ip-172-20-151-7.ec2.internal
gp-benchmark-szstx                1/1       Running   0          4m        100.96.14.2   ip-172-20-205-190.ec2.internal
gp-benchmark-xxktb                1/1       Running   0          4m        100.96.16.2   ip-172-20-83-19.ec2.internal
```

## Scaling In
```bash
$ kubectl scale jobs/gp-benchmark --replicas=6 --current-replicas=16
```

You should see in the cluster-autoscaler logs that nodes are now under utilized.
This starts a ~10 minute timer that resets if the node becomes used:
```bash
$ kubectl logs -f deploy/cluster-autoscaler --namespace=kube-system
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
I0222 23:53:34.323698       1 static_autoscaler.go:272] Calculating unneeded nodes
I0222 23:53:34.323850       1 utils.go:343] Skipping ip-172-20-41-90.ec2.internal - no node group config
I0222 23:53:34.324402       1 scale_down.go:148] Node ip-172-20-83-19.ec2.internal - utilization 0.025000
I0222 23:53:34.324432       1 scale_down.go:148] Node ip-172-20-121-42.ec2.internal - utilization 0.075000
I0222 23:53:34.324444       1 scale_down.go:148] Node ip-172-20-82-118.ec2.internal - utilization 0.025000
I0222 23:53:34.324454       1 scale_down.go:148] Node ip-172-20-181-222.ec2.internal - utilization 0.025000
I0222 23:53:34.324464       1 scale_down.go:148] Node ip-172-20-140-4.ec2.internal - utilization 0.025000
I0222 23:53:34.324475       1 scale_down.go:148] Node ip-172-20-205-190.ec2.internal - utilization 0.025000
I0222 23:53:34.324485       1 scale_down.go:148] Node ip-172-20-174-227.ec2.internal - utilization 0.025000
I0222 23:53:34.324498       1 scale_down.go:148] Node ip-172-20-56-70.ec2.internal - utilization 0.160000
I0222 23:53:34.324508       1 scale_down.go:148] Node ip-172-20-151-7.ec2.internal - utilization 0.025000
I0222 23:53:34.324523       1 scale_down.go:148] Node ip-172-20-221-153.ec2.internal - utilization 0.025000
I0222 23:53:34.324907       1 cluster.go:75] Fast evaluation: ip-172-20-83-19.ec2.internal for removal
I0222 23:53:34.324938       1 cluster.go:104] Fast evaluation: node ip-172-20-83-19.ec2.internal may be removed
I0222 23:53:34.324951       1 cluster.go:75] Fast evaluation: ip-172-20-121-42.ec2.internal for removal
I0222 23:53:34.325087       1 cluster.go:89] Fast evaluation: node ip-172-20-121-42.ec2.internal cannot be removed: non-daemonset, non-mirrored, non-pdb-assigned kube-system pod present: cluster-autoscaler-7c86fd487-8b7qc
I0222 23:53:34.325107       1 cluster.go:75] Fast evaluation: ip-172-20-82-118.ec2.internal for removal
I0222 23:53:34.325123       1 cluster.go:104] Fast evaluation: node ip-172-20-82-118.ec2.internal may be removed
I0222 23:53:34.325135       1 cluster.go:75] Fast evaluation: ip-172-20-181-222.ec2.internal for removal
I0222 23:53:34.325151       1 cluster.go:104] Fast evaluation: node ip-172-20-181-222.ec2.internal may be removed
I0222 23:53:34.325162       1 cluster.go:75] Fast evaluation: ip-172-20-140-4.ec2.internal for removal
I0222 23:53:34.325176       1 cluster.go:104] Fast evaluation: node ip-172-20-140-4.ec2.internal may be removed
I0222 23:53:34.325191       1 cluster.go:75] Fast evaluation: ip-172-20-205-190.ec2.internal for removal
I0222 23:53:34.325209       1 cluster.go:104] Fast evaluation: node ip-172-20-205-190.ec2.internal may be removed
I0222 23:53:34.325220       1 cluster.go:75] Fast evaluation: ip-172-20-174-227.ec2.internal for removal
I0222 23:53:34.325233       1 cluster.go:104] Fast evaluation: node ip-172-20-174-227.ec2.internal may be removed
I0222 23:53:34.325239       1 cluster.go:75] Fast evaluation: ip-172-20-56-70.ec2.internal for removal
I0222 23:53:34.325295       1 cluster.go:89] Fast evaluation: node ip-172-20-56-70.ec2.internal cannot be removed: non-daemonset, non-mirrored, non-pdb-assigned kube-system pod present: monitoring-influxdb-85cb4985d4-whkw4
I0222 23:53:34.325305       1 cluster.go:75] Fast evaluation: ip-172-20-151-7.ec2.internal for removal
I0222 23:53:34.325320       1 cluster.go:104] Fast evaluation: node ip-172-20-151-7.ec2.internal may be removed
I0222 23:53:34.325326       1 cluster.go:75] Fast evaluation: ip-172-20-221-153.ec2.internal for removal
I0222 23:53:34.325340       1 cluster.go:104] Fast evaluation: node ip-172-20-221-153.ec2.internal may be removed
I0222 23:53:34.325912       1 static_autoscaler.go:287] ip-172-20-83-19.ec2.internal is unneeded since 2018-02-22 23:53:24.149509506 +0000 UTC duration 10.176391073s
I0222 23:53:34.325932       1 static_autoscaler.go:287] ip-172-20-82-118.ec2.internal is unneeded since 2018-02-22 23:52:01.027183788 +0000 UTC duration 1m33.298738375s
I0222 23:53:34.325948       1 static_autoscaler.go:287] ip-172-20-181-222.ec2.internal is unneeded since 2018-02-22 23:52:11.379363392 +0000 UTC duration 1m22.946574975s
I0222 23:53:34.325964       1 static_autoscaler.go:287] ip-172-20-140-4.ec2.internal is unneeded since 2018-02-22 23:52:21.753718032 +0000 UTC duration 1m12.572236313s
I0222 23:53:34.325981       1 static_autoscaler.go:287] ip-172-20-205-190.ec2.internal is unneeded since 2018-02-22 23:53:03.806078505 +0000 UTC duration 30.519892505s
I0222 23:53:34.325997       1 static_autoscaler.go:287] ip-172-20-174-227.ec2.internal is unneeded since 2018-02-22 23:53:34.323939991 +0000 UTC duration 2.047273ms
I0222 23:53:34.326012       1 static_autoscaler.go:287] ip-172-20-151-7.ec2.internal is unneeded since 2018-02-22 23:52:21.753718032 +0000 UTC duration 1m12.572285809s
I0222 23:53:34.326028       1 static_autoscaler.go:287] ip-172-20-221-153.ec2.internal is unneeded since 2018-02-22 23:52:42.977513062 +0000 UTC duration 51.348506173s
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
```

If a node timer reaches 10 minutes of underutilization, then the node is
terminated and all pods currently running there are evicted and scheduled 
elsewhere:
```bash
$ kubectl logs -f deploy/cluster-autoscaler --namespace=kube-system
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
I0223 00:13:48.793115       1 static_autoscaler.go:292] Starting scale down
I0223 00:13:48.793126       1 scale_down.go:206] ip-172-20-121-42.ec2.internal was unneeded for 7m51.454042805s
I0223 00:13:48.793133       1 scale_down.go:206] ip-172-20-82-118.ec2.internal was unneeded for 499.622µs
I0223 00:13:48.793144       1 scale_down.go:206] ip-172-20-181-222.ec2.internal was unneeded for 10m14.902399479s
I0223 00:13:48.950660       1 scale_down.go:257] Scale-down: removing empty node ip-172-20-181-222.ec2.internal
I0223 00:13:48.950775       1 event.go:218] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"kube-system", Name:"cluster-autoscaler-status", UID:"f6f28417-182c-11e8-9975-12ab15281942", APIVersion:"v1", ResourceVersion:"12876", FieldPath:""}): type: 'Normal' reason: 'ScaleDownEmpty' Scale-down: removing empty node ip-172-20-181-222.ec2.internal
I0223 00:13:49.172360       1 aws_manager.go:147] Terminating EC2 instance: i-0c9a431090580850f
I0223 00:13:49.172579       1 event.go:218] Event(v1.ObjectReference{Kind:"Node", Namespace:"", Name:"ip-172-20-181-222.ec2.internal", UID:"07f0cd50-182b-11e8-9975-12ab15281942", APIVersion:"v1", ResourceVersion:"12893", FieldPath:""}): type: 'Normal' reason: 'ScaleDown' node removed by cluster autoscaler
```

Voila!

# Verifying Output Files (EFS)
After a job that mounts EFS has run (e.g. `gp-benchmark-efs.job.yaml`), the
files can be viewed and validated by mounting the EFS another container.

Create a container that mounts our shared EFS storage:
```bash
$ kubectl create -f efs-explorer.yaml
```

Then, we can use `kubectl exec -it` to get a shell into our `efs-explorer` 
container, where the shared storage is mounted:
```bash
$ kubectl exec -it $(kubectl get pods | grep efs-explorer | grep -v Terminating | awk '{print $1}') -- bash
```

Within the container, you should be able to execute `ls -al` or `cat` on any of
the files in your shared EFS mount to verify their contents are correct:
```
root@ip-172-20-181-222:/efs# ls -al
total 396916
drwxrws--x 2 root 2000   51200 Feb 22 23:53 .
drwxr-xr-x 1 root root    4096 Feb 23 00:07 ..
-rw-r--r-- 1 root 2000  759990 Feb 22 23:47 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_47_49.072134017_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:47 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_47_54.718770742_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:49 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_49_25.641628742_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:49 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_49_32.724794387_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_00.426809310_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_01.687641382_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_29.352803945_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_41.421683788_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_46.485538721_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:51 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_54.424429893_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:52 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_16.369684934_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:52 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_32.105706214_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:52 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_33.745727777_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:52 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_34.616033554_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:52 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_55.866746902_viz.tsv
-rw-r--r-- 1 root 2000  759990 Feb 22 23:53 17-AAG_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_53_03.232427120_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:47 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_47_51.850229024_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:47 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_47_54.512417316_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:49 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_49_27.499309539_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:49 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_49_27.694598674_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:50 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_50_58.637772798_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:51 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_01.158517360_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:51 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_30.177413463_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:51 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_46.532644033_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:51 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_47.905987262_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:51 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_51_57.560225009_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:52 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_18.405256986_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:52 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_33.640225648_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:52 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_35.605634927_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:52 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_37.693925857_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:53 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_59.648687362_viz.tsv
-rw-r--r-- 1 root 2000  761247 Feb 22 23:53 AEW541_bootstrap_net_correlation_pearson_Thu_22_Feb_2018_23_52_59.925833702_viz.tsv
   ...    ...    ...    ...    ...    ...    ...    ...    ...    ...    ...  
```
