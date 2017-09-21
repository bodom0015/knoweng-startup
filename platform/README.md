# KnowEnG Platform API / UI / IDE
See https://bitbucket.org/arivisualanalytics/nest/src

# Build
```bash
docker build -t bodom0015/cloud9-nest .
```

# Run
```bash
kubectl create -f loadbalancer.yaml,nest.yaml
```

## Parameters
Name          ~          Example Value
* `REDIS_HOST` ~ localhost
* `POSTGRES_HOST` ~ localhost

# Develop
```bash
kubectl create -f cloud9.yaml
```