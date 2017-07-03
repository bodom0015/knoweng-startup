FROM knowengdev/gene_prioritization_pipeline:04_26_2017

ENV ANALYSIS_METHOD="bootstrap_net_correlation" \
    CORRELATION_METHOD="pearson" \
    GP_NETWORK_NAME_FULL_PATH="../data/networks/TEST_1_gene_gene.edge" \
    SPREADSHEET_NAME_FULL_PATH="../data/spreadsheets/TEST_1_gene_sample.tsv" \
    PHENOTYPE_NAME_FULL_PATH="./data/spreadsheets/TEST_multi_drug_response_pearson.txt" \
    NUMBER_OF_BOOTSTRAPS="10" \
    COLS_SAMPLING_FRACTION="0.9" \
    RESULTS_DIRECTORY="./run_dir/results" \
    RWR_MAX_ITERATIONS="100" \
    RWR_CONVERGENCE_TOLERENCE="0.0001" \
    RWR_RESTART_PROBABILITY="0.5" \
    TOP_BETA_OF_SORT="3"

WORKDIR /home/test
COPY parameters.yml entrypoint.sh ./

CMD [ "./entrypoint.sh" ]
