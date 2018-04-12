# Intro to Kubernetes on AWS
Deployment commands / notes

# Final result:
- Single-node: https://knowdev2.knoweng.org/static/index.html
- Multi-node: https://knowkube.ndslabs.org/static/index.html

# References:
- https://opensource.ncsa.illinois.edu/confluence/display/~lambert8/KnowEnG+Kubernetes+Deployment
- https://github.com/bodom0015/knoweng-startup
- https://github.com/bodom0015/knoweng-startup/tree/master/pipelines
- https://github.com/bodom0015/platform/tree/master/NOTES.md

# External References:
- Workshop Materials: https://github.com/aws-samples/aws-workshop-for-kubernetes
- EFS Provisioner: https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs
- Kubernetes v1.8 Documentation: https://v1-8.docs.kubernetes.io/docs/home/
- Interactive Kubernetes Tutorial: https://v1-8.docs.kubernetes.io/docs/tutorials/kubernetes-basics/

# Required permissions
In order to deploy a Cloud9 AWS from a CloudFormation template and deploy new Kubernetes clusters via `kops`, you will need to have the following permissions:
- AWSCloud9EnvironmentMember
- AWSCloud9Administrator
- AWSLambdaFullAccess
- IAMFullAccess
- AmazonS3FullAccess
- AmazonEC2FullAccess
- AmazonVPCFullAccess
- AWSCloud9User
- AmazonSNSFullAccess
- CloudFormationFullAccess (inline)
- EC2CreateModifyDeleteNetworkInterfaces (inline)
- EFSFullAccess (inline)

NOTE: this was easily the least pleasant part

# Learning the Basics
The following section describes the basics of working with clusters. You would likely need to learn this as a developer/user working with and debugging applications on Kubernetes, to spin up test clusters during development, or as to test the deployment process.

## Terminology
There is a lot of new terminology involved in Kubernetes.

Their [official glossary](https://kubernetes.io/docs/reference/glossary/?fundamental=true) does a much better job of formally defining their terms than I ever could.

## Cloud9 AWS
- https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/01-path-basics/101-start-here#aws-cloud9-console ->
- https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=k8s-workshop&templateURL=https://s3.amazonaws.com/aws-kubernetes-artifacts/lab-ide-vpc.template

### Developer Instance (single-node)
If you're only looking for the 
Cloud9 can function as a standalone developer instance - it even comes with Docker pre-installed!

Simply clone this repo and follow the `./kube.sh` to start up Kubernetes. (In this case, you will need to choose a larger machine size when deploying Cloud9, since the default is `t2.micro`)

While untested, that's really it! Now you should be able to follow the rest of the instructions from the [README](README.md) to get started!

Furthermore, this could be a more secure drop-in replacement for our existing `knowdev` VMs - instead of running Cloud9 as a container and SSHing back to the host, we are simply running Cloud9 on the host.

### Production Instance (multi-node)
This is a bit more involved, depending on how much of it you will need.

Run the following command in your Cloud9 terminal:
```bash
aws s3 cp s3://aws-kubernetes-artifacts/lab-ide-build.sh . && \
chmod +x lab-ide-build.sh && \
. ./lab-ide-build.sh
```

This will perform the following in your Cloud9 instance:
- Install kubectl
- Install kops
- Install jq
- Configure the aws CLI
- clones the [Workshop Materials](https://github.com/aws-samples/aws-workshop-for-kubernetes/) into your Cloud9 workspace with git

Reminder:
If you plan to use `kops`, you'll want to disable temporary credntials, as described at the end of the [Build Script](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/01-path-basics/101-start-here#build-script) section of the workshop tutorial setup

Choose a Cluster Name:
```bash
export CLUSTER_NAME="knowkube.cluster.k8s.local"
```

Add any exported environment variables to Cloud9's ~/.bash_profile, so they are restored in case your session is terminated

For example:
```bash
AWS_AVAILABILITY_ZONES=us-east-1a,us-east-1b,us-east-1c,us-east-1d,us-east-1e,us-east-1f
KOPS_STATE_STORE=s3://kops-state-store-someuuid
CLUSTER_NAME="knowkube.cluster.k8s.local"
export AWS_AVAILABILITY_ZONES KOPS_STATE_STORE CLUSTER_NAME
```

Run `kops` to deploy a new cluster

```bash
kops create cluster \
  --name $CLUSTER_NAME \
  --node-size="m4.large" \
  --zones $AWS_AVAILABILITY_ZONES \
  --yes
```

It can take several minutes to set up your cluster - be patient. You can run the following command to check if your cluster is completely ready.
```bash
kops validate cluster
```

See https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/01-path-basics/102-your-first-cluster#single-master-cluster

## Using `kubectl` to manage resources
`kubectl` is how you interact with the cluster as an admininstrator.

* `kubectl get` can be used to list existing resources
* `kubectl create` can be used to create new resources
* `kubectl apply` or `kubectl replace` can be used to update existing resources, or create them if they do not already exist
* `kubectl delete` can be used to teardown existing resources

* `kubectl run` can be used to run a new application
* `kubectl logs` can be used to check the logs of existing containers
* `kubectl expose` can be used to expose your application to other containers in the cluster

## Running a new application
You can run a simple application using `kubectl run`.

Using `kubectl run --help` will list some examples:
```bash
$ kubectl run --help
Create and run a particular image, possibly replicated. 

Creates a deployment or job to manage the created container(s).

Examples:
  # Start a single instance of nginx.
  kubectl run nginx --image=nginx
  
  # Start a single instance of hazelcast and let the container expose port 5701 .
  kubectl run hazelcast --image=hazelcast --port=5701
  
  # Start a single instance of hazelcast and set environment variables "DNS_DOMAIN=cluster" and "POD_NAMESPACE=default"
in the container.
  kubectl run hazelcast --image=hazelcast --env="DNS_DOMAIN=cluster" --env="POD_NAMESPACE=default"
  
  # Start a single instance of hazelcast and set labels "app=hazelcast" and "env=prod" in the container.
  kubectl run hazelcast --image=nginx --labels="app=hazelcast,env=prod"
  
  # Start a replicated instance of nginx.
  kubectl run nginx --image=nginx --replicas=5
  
  # Dry run. Print the corresponding API objects without creating them.
  kubectl run nginx --image=nginx --dry-run
  
  # Start a single instance of nginx, but overload the spec of the deployment with a partial set of values parsed from
JSON.
  kubectl run nginx --image=nginx --overrides='{ "apiVersion": "v1", "spec": { ... } }'
  
  # Start a pod of busybox and keep it in the foreground, don't restart it if it exits.
  kubectl run -i -t busybox --image=busybox --restart=Never
  
  # Start the nginx container using the default command, but use custom arguments (arg1 .. argN) for that command.
  kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN>
  
  # Start the nginx container using a different command and custom arguments.
  kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN>
  
  # Start the perl container to compute π to 2000 places and print it out.
  kubectl run pi --image=perl --restart=OnFailure -- perl -Mbignum=bpi -wle 'print bpi(2000)'
  
  # Start the cron job to compute π to 2000 places and print it out every 5 minutes.
  kubectl run pi --schedule="0/5 * * * ?" --image=perl --restart=OnFailure -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

Some other examples:
- Running an NGINX Deployment: https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/
- Redis/PHP Guestbook application: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

## Exposing an application
`kubectl expose` can be used to expose one or more ports of your application to other containers in the cluster.

`kubectl expose --help` will provide more usage examples:
```bash
$ kubectl expose --help
Expose a resource as a new Kubernetes service. 

Looks up a deployment, service, replica set, replication controller or pod by name and uses the selector for that
resource as the selector for a new service on the specified port. A deployment or replica set will be exposed as a
service only if its selector is convertible to a selector that service supports, i.e. when the selector contains only
the matchLabels component. Note that if no port is specified via --port and the exposed resource has multiple ports, all
will be re-used by the new service. Also if no labels are specified, the new service will re-use the labels from the
resource it exposes. 

Possible resources include (case insensitive): 

pod (po), service (svc), replicationcontroller (rc), deployment (deploy), replicaset (rs)

Examples:
  # Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000.
  kubectl expose rc nginx --port=80 --target-port=8000
  
  # Create a service for a replication controller identified by type and name specified in "nginx-controller.yaml",
which serves on port 80 and connects to the containers on port 8000.
  kubectl expose -f nginx-controller.yaml --port=80 --target-port=8000
  
  # Create a service for a pod valid-pod, which serves on port 444 with the name "frontend"
  kubectl expose pod valid-pod --port=444 --name=frontend
  
  # Create a second service based on the above service, exposing the container port 8443 as port 443 with the name
"nginx-https"
  kubectl expose service nginx --port=443 --target-port=8443 --name=nginx-https
  
  # Create a service for a replicated streaming application on port 4100 balancing UDP traffic and named 'video-stream'.
  kubectl expose rc streamer --port=4100 --protocol=udp --name=video-stream
  
  # Create a service for a replicated nginx using replica set, which serves on port 80 and connects to the containers on
port 8000.
  kubectl expose rs nginx --port=80 --target-port=8000
  
  # Create a service for an nginx deployment, which serves on port 80 and connects to the containers on port 8000.
  kubectl expose deployment nginx --port=80 --target-port=8000
```

## Using `kubectl` to check container logs
`kubectl logs <pod-name>` can be used to view the logs of the containers running in a pod.

If there is more than one container in the pod, you can use `-c` to specify which container's logs to view.

`kubectl logs --help` will also provide more usage examples:
```bash
$ kubectl logs --help
Print the logs for a container in a pod or specified resource. If the pod has only one container, the container name is
optional.

Aliases:
logs, log

Examples:
  # Return snapshot logs from pod nginx with only one container
  kubectl logs nginx
  
  # Return snapshot logs for the pods defined by label app=nginx
  kubectl logs -lapp=nginx
  
  # Return snapshot of previous terminated ruby container logs from pod web-1
  kubectl logs -p -c ruby web-1
  
  # Begin streaming the logs of the ruby container in pod web-1
  kubectl logs -f -c ruby web-1
  
  # Display only the most recent 20 lines of output in pod nginx
  kubectl logs --tail=20 nginx
  
  # Show all logs from pod nginx written in the last hour
  kubectl logs --since=1h nginx
  
  # Return snapshot logs from first container of a job named hello
  kubectl logs job/hello
  
  # Return snapshot logs from container nginx-1 of a deployment named nginx
  kubectl logs deployment/nginx -c nginx-1
```


# Advanced
You would likely need to learn this to run/configure new applications on Kubernetes, or to administrate multi-node clusters.

## Pulling Private Docker images (Intro to Secrets)
For more details, see: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

In order to pull Docker images from private repositories, you'll need to embed your Docker credentials in ` Secret.

"Secrets" are Kubernetes way of packaging and mounting sensitive data into your containers, and are usually mounted into your container as files.

To create a secret from your Docker credentials, run the following:
```bash
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

NOTE: The "registry-server" for DockerHub is `docker.io`. 

## Exposing applications to the cluster using Services
"Services" are static internal IPs that your containers can use to talk to one another

- https://kubernetes.io/docs/concepts/services-networking/service/
- https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/
- https://kubernetes.io/docs/tasks/access-application-cluster/connecting-frontend-backend/

Discovering services:
- https://kubernetes.io/docs/concepts/services-networking/service/#discovering-services

Exposing applications externally using Ingress rules:
"Ingress" rules map a particular hostname and path to a Kubernetes Service, allowing it to accept external requests from the public internet

- https://kubernetes.io/docs/concepts/services-networking/ingress/
- https://github.com/nginxinc/kubernetes-ingress/tree/master/examples/complete-example

### Ingress Controller Options
There are slight differences between NGINX ILB and the Google Cloud LoadBalancer
- Requires Google Cloud (obviously): https://github.com/kubernetes/ingress-gce
- For everyone else: https://github.com/kubernetes/ingress-nginx

There are also some community customized Ingress controllers, such as the [AWS LoadBalancer](https://github.com/coreos/alb-ingress-controller)

## Enable Cluster Monitoring
For more details, see: [201: Cluster Monitoring](https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/201-cluster-monitoring)

### Kubernetes Dashboard
Start up the Kubernetes Dashboard by running the following:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

### Heapster
Start up Heapster / InfluxDB / Grafana by running the following:
```bash
kubectl apply -f aws-workshop-for-kubernetes/02-path-working-with-clusters/201-cluster-monitoring/templates/heapster/
```

Once those services come online, you should be able to run a new `kubectl` command to print node resource utilization:
```bash
kubectl top nodes
```

### Accessing unexposed applications externally using kubectl proxy:
For more details, see: https://github.com/bodom0015/knoweng-startup/tree/master/pipelines#monitoring-your-cluster-via-web-ui

#### Installing `kubectl` manually
For this next trick, you'll need to [install `kubectl` locally](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Once installed, you'll want to copy the contents of `~/.kube/config` from your Cloud9 AWS instance to the same file on your local machine. This way, your local `kubectl` calls will be sent to the same cluster that you just set from in Cloud9!

Test it out with `kubectl get nodes` - you should see the same nodes as if you were running from your Cloud9 AWS terminal.

#### Using `kubectl proxy`

Both Heapster and the Kubernetes Dashboard have web interfaces, but are not exposed externally. We could expose them with Ingress rules and configure authentication (Basic Auth or OAuth2) over those rules, but instead lets try using `kubectl proxy`.

`kubectl proxy` is a way to open a secure tunnel from your local machine to a cluster service that hasn't been exposed externally. `kubectl` will authenticate using the token in you `~/.kube/config` file 

This effectively uses your kubectl access token to tunnel your localhost port 8001 to the cluster's unexposed admin monitoring services.

Your local machine's browser should now resolve the following link(s):
* Kubernetes Dashboard: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default
* Grafana: http://localhost:8001/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy/?orgId=1

## Creating Instance Groups with `kops` and enabling Cluster Autoscaling:
* `kops create ig pipes`
    - Edit minSize (1) / maxSize (8) / instanceType (m4.xlarge) and add any additional node labels you want to apply
* `kops update cluster --name $CLUSTER_NAME --yes`
* `kops rolling-update cluster` (this shouldn't be needed, but run it anyways just in case any changes need to be applied)
* `vi aws-workshop-for-kubernetes/02-path-working-with-clusters/205-cluster-autoscaling/templates/2-10-autoscaler.yaml`
    * Edit region in env var
    * Edit group name and pool size `--nodes` argument of the container command
        * NOTE: this argument is formatted as `--nodes=minSize:maxSize:instanceGroupName.clusterName
        * In my example above, this
* `kubectl apply -f aws-workshop-for-kubernetes/02-path-working-with-clusters/205-cluster-autoscaling/templates/2-10-autoscaler.yaml`

# Expert
You would likely need to learn this to setup and adminstrate a production Kubernetes cluster

## Aggregate all container logs to a searchable UI (EFK)
- https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/02-path-working-with-clusters/204-cluster-logging-with-EFK

NOTE: I did not follow the steps to enable logging (I was unsure about costs), but the rest of this repo worked very well so I expect it should be fairly straight forward


## Volumes, Persistent Volumes/Claims
- Volumes: https://kubernetes.io/docs/concepts/storage/volumes/
- Persistent Volumes: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

# Mounting from EFS
- Dev (uses hostPath): https://github.com/bodom0015/knoweng-startup/blob/master/platform/nest.dev.yaml
- Production (requires EFS): https://github.com/bodom0015/knoweng-startup/blob/master/platform/nest.prod.yaml
- To set up EFS: https://github.com/bodom0015/knoweng-startup/tree/master/efs
