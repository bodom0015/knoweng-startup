# ndslabs-knoweng
An experiment in running KnowEnG pipelines as Kubernetes Jobs

# Prerequisites
* Docker (preferrably 1.10.x - 1.13.x)

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
kubectl create -f  gp.job.yaml
```


To run the Gene Set Characterization pipeline:
```bash
kubectl create -f  gsc.job.yaml
```


To run the Samples Clustering pipeline:
```bash
kubectl create -f  sc.job.yaml
```
