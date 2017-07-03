# KnowEnG Data Cleanup Pipeline
See https://github.com/KnowEnG/Data_Cleanup_Pipeline

# Build
```bash
docker build -t bodom0015/data-cleanup .
```

# Run
```bash
docker run -it -e PIPELINE_TYPE="gene_prioritization_pipeline"  -e ... -v local_results:/home/test/run_dir bodom0015/data-cleanup
```

NOTE: You can override any of the default parameters defined below using `-e`

## Parameters
Name          ~          Example Value
* `SPREADSHEET_NAME_FULL_PATH` ~ ../data/spreadsheets/TEST_1_gene_expression.tsv
* `PHENOTYPE_NAME_FULL_PATH` ~ ../data/spreadsheets/TEST_1_phenotype.tsv
* `RESULTS_DIRECTORY` ~ ./run_dir/results
* `TAXON_ID` ~ 9606
* `SOURCE_HINT` ~ ''
* `PIPELINE_TYPE` ~ gene_prioritization_pipeline
* `REDIS_HOST` ~ localhost
* `REDIS_PASS` ~ password
* `REDIS_PORT` ~ 6379
