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
3. [Install an NFS Client](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html#mounting-fs-install-nfsclient)
4. [Mount the EFS using hte DNS name](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html)
5. 

# Deploy the platform