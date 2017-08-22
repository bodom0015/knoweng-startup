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

# Install redis-tools
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
      python-pip \
      redis-tools && \
    pip install redis && \
    apt-get -qq autoremove && \
    apt-get -qq autoclean && \
    apt-get -qq clean all && \
    rm -rf /var/cache/apk/*

# Download redis work queue implementation
ADD https://kubernetes.io/docs/tasks/job/fine-parallel-processing-work-queue/rediswq.py?raw=true ./rediswq.py

WORKDIR /home/test
COPY parameters.yml entrypoint.sh ./

CMD [ "./entrypoint.sh" ]
