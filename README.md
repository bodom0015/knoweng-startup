# ndslabs-knoweng
An experiment in running KnowEnG pipelines as Kubernetes Jobs

# Prerequisites
* Docker (preferrably 1.10.x - 1.13.x)

# Building all Docker Images
To quickly build up all of the pipeline images:
```bash
docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workdir -w /workdir docker/compose:${DOCKER_VERSION} build
```

# Running Hyperkube
To run a development Kubernetes cluster (via Docker):
```bash
git clone https://github.com/nds-org/ndslabs-startup
cd ndslabs-startup
./kube.sh
```

NOTE: You'll need to manually add the path the the `kubectl` binary to your `$PATH`.

# Running Pipelines
To run the Gene Prioritization pipeline:
```bash
kubectl create -f gp.job.yaml
```

To run the Gene Set Characterization pipeline:
```bash
kubectl create -f gsc.job.yaml
```

To run the Samples Clustering pipeline:
```bash
kubectl create -f sc.job.yaml
```

This will create the Job objects on your Kubernetes cluster. Job objects themselves don't execute anything (and therefore don't keep logs), but they will spawn Pods (groups of containers) to execute the desired work item(s).

# Monitoring Jobs
To view the status of your jobs and their pods:
```bash
core@nds842-master1 ~/ndslabs-knoweng $ kubectl get jobs,pods -a
NAME           DESIRED   SUCCESSFUL   AGE
jobs/gp-test   1         1            1m

NAME                            READY     STATUS      RESTARTS   AGE
po/gp-test-hzcq8                0/1       Completed   0          1m
```

This will list off all running jobs and their respectives pods (replicas).

NOTE: The `-a` flag tells to Kubernetes to include pods that have `Completed` in the returned list.

## Viewing Logs
To view the logs of an individual pod (where your work items are being executed):
```bash
kubectl logs -f gp-test-hzcq8 
```

# Cleaning Up Jobs
Kubernetes leaves it up to the user to delete their own Job objects, which stick around indefinitely to ease debugging.

To delete a job (and trigger clean up its corresponding pods):
```bash
kubectl delete jobs/gp-test
```

To delete all jobs:
```bash
kubectl delete jobs --all
```
