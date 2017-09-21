# KnowEnG Samples Clustering Pipeline
See https://github.com/KnowEnG/Samples_Clustering_Pipeline

# Build
```bash
docker build -t bodom0015/samples-clustering .
```

# Run
```bash
docker run -it -e METHOD=cc_net_nmf -e ... -v $(pwd)/local_results:/home/test/run_dir bodom0015/samples-clustering
```

NOTE: You can override any of the default parameters defined below using `-e`

## Parameters
Name          ~          Example Value
* `METHOD` ~ cc_net_nmf
* `GG_NETWORK_NAME_FULL_PATH` ~ ../data/networks/keg_ST90_4col.edge
* `SPREADSHEET_NAME_FULL_PATH` ~ ../data/spreadsheets/tcga_ucec_somatic_mutation_data.df
* `PHENOTYPE_NAME_FULL_PATH` ~ ../data/spreadsheets/UCEC_phenotype.txt
* `THRESHOLD` ~ 10
* `RESULTS_DIRECTORY` ~ ./run_dir/results
* `TMP_DIRECTORY` ~ ./run_dir/tmp
* `NUMBER_OF_CLUSTERS` ~ 3
* `NUMBER_OF_BOOTSTRAPS` ~ 4
* `ROWS_SAMPLING_FRACTION` ~ 0.8
* `COLS_SAMPLING_FRACTION` ~ 0.8
* `NMF_CONV_CHECK_FREQ` ~ 50
* `NMF_MAX_INVARIANCE` ~ 200
* `NMF_MAX_ITERATIONS` ~ 10000
* `NMF_PENALTY_PARAMETER` ~ 1400
* `RWR_MAX_ITERATIONS` ~ 100
* `RWR_RESTART_PROBABILITY` ~ 0.7
* `RWR_CONVERGENCE_TOLERENCE` ~ 0.0001
* `TOP_NUMBER_OF_GENES` ~ 100
* `PROCESSING_METHOD` ~ serial
* `CLUSTER_IP_ADDRESS` ~
* `CLUSTER_SHARED_RAM` ~ /mnt/ramdisk/knoweng/
* `CLUSTER_SHARED_VOLUME` ~ /mnt/clustershare/knoweng/
