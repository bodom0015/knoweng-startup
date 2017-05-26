# KnowEnG Gene Prioritization Pipeline

# Build
```bash
docker build -t bodom0015/gene-prioritization .
```

# Run
```bash
docker run -it e ANALYSIS_METHOD=pearson -e ... -v local_results:/home/test/run_dir bodom0015/gene-prioritization
```

## Parameters
Name          ~          Example Value
* `ANALYSIS_METHOD` ~ bootstrap_net_correlation
* `CORRELATION_METHOD` ~ pearson
* `GP_NETWORK_NAME_FULL_PATH` ~ path/to/network/file
* `SPREADSHEET_NAME_FULL_PATH` ~ path/to/features/file
* `PHENOTYPE_NAME_FULL_PATH` ~ path/to/response/file
* `NUMBER_OF_BOOTSTRAPS` ~ 10
* `COLS_SAMPLING_FRACTION` ~ 0.9
* `RWR_MAX_ITERATIONS` ~ 100
* `RWR_CONVERGENCE_TOLERENCE` ~ "1.0e-2" or "0.0001"
* `RWR_RESTART_PROBABILITY` ~ 0.5
* `TOP_BETA_OF_SORT` ~ 3

# TODO
* parameterize input/output paths
