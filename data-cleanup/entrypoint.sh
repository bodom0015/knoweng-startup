#!/bin/bash

OUTPUT_DIR=/home/test/run_dir/results

# Ensure results folder exists
mkdir -p $OUTPUT_DIR

# Build up a parameters from our env
cat parameters.yml | sed -e "s#{{[ ]*spreadsheet_name_full_path[ ]*}}#${SPREADSHEET_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*phenotype_name_full_path[ ]*}}#${PHENOTYPE_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*results_directory[ ]*}}#${RESULTS_DIRECTORY}#" \
    -e "s#{{[ ]*correlation_measure[ ]*}}#${CORRELATION_MEASURE}#" \
    -e "s#{{[ ]*taxon_id[ ]*}}#${TAXON_ID}#" \
    -e "s#{{[ ]*pipeline_type[ ]*}}#${PIPELINE_TYPE}#" \
    -e "s#{{[ ]*redis_host[ ]*}}#${REDIS_HOST}#" \
    -e "s#{{[ ]*redis_pass[ ]*}}#${REDIS_PASS}#" \
    -e "s#{{[ ]*redis_port[ ]*}}#${REDIS_PORT}#" > ./job-parameters.yml

# Print parameters / progress to the logs
echo "Running Data Cleanup Pipeline with the following parameters:"
cat ./job-parameters.yml

# Run the DC pipeline
python3 ../src/data_cleanup.py -run_directory ./ -run_file job-parameters.yml || exit 1

echo 'Job complete!'
echo "Output directory:"
ls -al $OUTPUT_DIR
