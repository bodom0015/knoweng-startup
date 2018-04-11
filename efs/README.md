# AWS EFS
The YAML templates contained in this directory are for deploying
EFS-backed pods to AWS for the purpose of running the KnowEnG platform
in production-mode.

# Create an EFS
See https://console.aws.amazon.com/efs/home?region=us-east-1#/filesystems

# Adjust the VPC / Security Groups
See https://docs.aws.amazon.com/efs/latest/ug/security-considerations.html#network-access

# Deploy the Provisioner
```bash
kubectl apply -f efs-provisioner.yaml
```

# Create the PVCs
```bash
kubectl apply -f pvcs/
```

# Populate the EFS
1. Spin up a tiny instance in the same zone/region/VPC as your Kubernetes cluster and EFS
2. SSH into your new instance
3. [Install an NFS client](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html#mounting-fs-install-nfsclient)
4. [Mount the EFS using the DNS name](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html)
5. Copy necessary Knowledge Network files from S3 (or another disk) to the "efs-networks-someuuid" subdriectory on the EFS
    * WARNING: this subdirectory is managed by Kubernetes, and will be **DELETED** if you choose to delete your PVC. 
    * **DO NOT** explicitly delete your PVC unless you want Kubernetes to delete the data housed within it.

# Deploy the Production version of the KnowEnG Platform
```bash
kubectl delete -f ../platform/nest.dev.yaml
kubectl apply -f ../platform/nest.prod.yaml
```

NOTE: this has not yet been tested with HubZero, but should auth exactly the same as the current system.