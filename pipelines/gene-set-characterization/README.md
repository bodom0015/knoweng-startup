# KnowEnG Gene Set Characterization Pipeline
See https://github.com/KnowEnG/Geneset_Characterization_Pipeline

# Build
```bash
docker build -t bodom0015/gene-set-characterization .
```

# Run
```bash
docker run -it -e ANALYSIS_METHOD=bootstrap_net_correlation -e ... -v $(pwd)/local_results:/home/test/run_dir bodom0015/gene-set-characterization
```

NOTE: You can override any of the default parameters defined below using `-e`

## Parameters
Name          ~          Example Value
* `ANALYSIS_METHOD` ~ bootstrap_net_correlation
* `CORRELATION_METHOD` ~ pearson
* `GP_NETWORK_NAME_FULL_PATH` ~ ../data/networks/TEST_1_gene_gene.edge
* `SPREADSHEET_NAME_FULL_PATH` ~ ../data/spreadsheets/TEST_1_gene_sample.tsv
* `PHENOTYPE_NAME_FULL_PATH` ~ ../data/spreadsheets/TEST_multi_drug_response_pearson.txt
* `NUMBER_OF_BOOTSTRAPS` ~ 10
* `COLS_SAMPLING_FRACTION` ~ 0.9
* `RESULTS_DIRECTORY` ~ ./run_dir/results
* `RWR_MAX_ITERATIONS` ~ 100
* `RWR_CONVERGENCE_TOLERENCE` ~ "1.0e-2" or "0.0001"
* `RWR_RESTART_PROBABILITY` ~ 0.5
* `TOP_BETA_OF_SORT` ~ 3
