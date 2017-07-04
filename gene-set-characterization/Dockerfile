FROM knowengdev/geneset_characterization_pipeline:04_07_2017

ENV ANALYSIS_METHOD="bootstrap_net_correlation" \
    CORRELATION_METHOD="pearson" \
    GP_NETWORK_NAME_FULL_PATH="../data/networks/TEST_1_gene_gene.edge" \
    SPREADSHEET_NAME_FULL_PATH="../data/spreadsheets/TEST_1_gene_sample.tsv" \
    PHENOTYPE_NAME_FULL_PATH="../data/spreadsheets/TEST_multi_drug_response_pearson.txt" \
    NUMBER_OF_BOOTSTRAPS="10" \
    COLS_SAMPLING_FRACTION="0.9" \
    RESULTS_DIRECTORY="./run_dir/results" \
    RWR_MAX_ITERATIONS="100" \
    RWR_CONVERGENCE_TOLERENCE="0.0001" \
    RWR_RESTART_PROBABILITY="0.5" \
    TOP_BETA_OF_SORT="3" 

WORKDIR /home/data/networks
RUN ls -al && gunzip -f STRING_experimental_gene_gene.edge.gz && \
    gunzip -f TEST_1_gene_gene.edge.gz && \
    gunzip -f TEST_1_property_gene.edge.gz && \
    gunzip -f kegg_pathway_property_gene.edge.gz

WORKDIR /home/data/spreadsheets
RUN ls -al && gunzip -f ProGENI_rwr20_STExp_GDSC_500.rname.gxc.tsv.gz && \
    gunzip -f ProGENI_rwr20_STExp_GDSC_500_MAP.rname.gxc.tsv.gz && \
    gunzip -f TEST_1_spreadsheet.tsv.gz && \
    gunzip -f TEST_1_spreadsheet_MAP.tsv.gz

WORKDIR /home/test
COPY parameters.yml entrypoint.sh ./

CMD [ "./entrypoint.sh" ]
