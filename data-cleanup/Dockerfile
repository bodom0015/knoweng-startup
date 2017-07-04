FROM knowengdev/data_cleanup_pipeline:04_17_2017

ENV SPREADSHEET_NAME_FULL_PATH="../data/spreadsheets/TEST_1_gene_expression.tsv" \
    PHENOTYPE_NAME_FULL_PATH="../data/spreadsheets/TEST_1_phenotype.tsv" \
    RESULTS_DIRECTORY="./run_dir/results" \
    CORRELATION_MEASURE="pearson" \
    TAXON_ID="9606" \
    SOURCE_HINT="" \
    PIPELINE_TYPE="gene_prioritization_pipeline" \
    REDIS_HOST="localhost" \
    REDIS_PASS="" \
    REDIS_PORT="6379"

WORKDIR /home/test
COPY parameters.yml entrypoint.sh ./

CMD [ "./entrypoint.sh" ]
