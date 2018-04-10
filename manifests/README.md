# HyperKube
A HyperKube cluster is composed of several microservice Docekr containers:
* etcd - stores configuration about all Kubernetes resources in the cluster
* kubelet - executes and reports the status of pods running on its node
* apiserver - Kubernetes REST API (where `kubectl` send all of its requests)
* scheduler - monitors resource usage and optimally schedules pods
* controller-manager - guarantees the desired number of replicas for each pod
* proxy - allows a kubectl user (admin) to tunnel into an unexposed service

# Manifests
The manifests contained in this directory are used to configure the 
different Docker containers comprising a HyperKube (single-node, 
containerized) Kubernetes cluster.

**DO NOT** modify these manifests unless you know what you are doing.