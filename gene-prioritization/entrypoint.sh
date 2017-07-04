#!/bin/bash

OUTPUT_DIR=/home/test/run_dir/results

# Ensure results folder exists
mkdir -p $OUTPUT_DIR

# Build up a parameters from our env
cat parameters.yml | sed -e "s#{{[ ]*analysis_method[ ]*}}#${ANALYSIS_METHOD}#" \
    -e "s#{{[ ]*correlation_method[ ]*}}#${CORRELATION_METHOD}#" \
    -e "s#{{[ ]*gg_network_name_full_path[ ]*}}#${GG_NETWORK_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*spreadsheet_name_full_path[ ]*}}#${SPREADSHEET_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*phenotype_name_full_path[ ]*}}#${PHENOTYPE_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*results_directory[ ]*}}#${RESULTS_DIRECTORY}#" \
    -e "s#{{[ ]*number_of_bootstraps[ ]*}}#${NUMBER_OF_BOOTSTRAPS}#" \
    -e "s#{{[ ]*cols_sampling_fraction[ ]*}}#${COLS_SAMPLING_FRACTION}#" \
    -e "s#{{[ ]*rwr_max_iterations[ ]*}}#${RWR_MAX_ITERATIONS}#" \
    -e "s#{{[ ]*rwr_convergence_tolerence[ ]*}}#${RWR_CONVERGENCE_TOLERANCE}#" \
    -e "s#{{[ ]*rwr_restart_probability[ ]*}}#${RWR_RESTART_PROBABILITY}#" \
    -e "s#{{[ ]*top_beta_of_sort[ ]*}}#${TOP_BETA_OF_SORT}#" > ./job-parameters.yml

# Print parameters / progress to the logs
echo "Running Gene Prioritization Pipeline with the following parameters:"
cat ./job-parameters.yml

# Run the GP pipeline
python3 ../src/gene_prioritization.py -run_directory ./ -run_file job-parameters.yml || exit 1

echo 'Job complete!'
echo "Output directory:"
ls -al $OUTPUT_DIR
