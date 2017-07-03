#!/bin/bash
set -e

OUTPUT_DIR=/home/test/run_dir/results

# Ensure results folder exists
mkdir -p $OUTPUT_DIR

# Build up a parameters from our env
cat parameters.yml | sed -e "s#{{[ ]*analysis_method[ ]*}}#${ANALYSIS_METHOD}#" \
    -e "s#{{[ ]*gg_network_name_full_path[ ]*}}#${GG_NETWORK_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*spreadsheet_name_full_path[ ]*}}#${SPREADSHEET_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*phenotype_name_full_path[ ]*}}#${PHENOTYPE_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*threshold[ ]*}}#${THRESHOLD}#" \
    -e "s#{{[ ]*number_of_clusters[ ]*}}#${NUMBER_OF_CLUSTERS}#" \
    -e "s#{{[ ]*number_of_bootstraps[ ]*}}#${NUMBER_OF_BOOTSTRAPS}#" \
    -e "s#{{[ ]*cols_sampling_fraction[ ]*}}#${COLS_SAMPLING_FRACTION}#" \
    -e "s#{{[ ]*rows_sampling_fraction[ ]*}}#${ROWS_SAMPLING_FRACTION}#" \
    -e "s#{{[ ]*nmf_conv_check_freq[ ]*}}#${NMF_CONV_CHECK_FREQ}#" \
    -e "s#{{[ ]*nmf_max_invariance[ ]*}}#${NMF_MAX_INVARIANCE}#" \
    -e "s#{{[ ]*nmf_max_iterations[ ]*}}#${NMF_MAX_ITERATIONS}#" \
    -e "s#{{[ ]*nmf_penalty_parameter[ ]*}}#${NMF_PENALTY_PARAMETER}#" \
    -e "s#{{[ ]*rwr_max_iterations[ ]*}}#${RWR_MAX_ITERATIONS}#" \
    -e "s#{{[ ]*rwr_convergence_tolerence[ ]*}}#${RWR_CONVERGENCE_TOLERANCE}#" \
    -e "s#{{[ ]*rwr_restart_probability[ ]*}}#${RWR_RESTART_PROBABILITY}#" \
    -e "s#{{[ ]*processing_method[ ]*}}#${PROCESSING_METHOD}#" \
    -e "s#{{[ ]*cluster_ip_addresses[ ]*}}#${CLUSTER_IP_ADDRESSES}#" \
    -e "s#{{[ ]*cluster_shared_ram[ ]*}}#${CLUSTER_SHARED_RAM}#" \
    -e "s#{{[ ]*cluster_shared_volume[ ]*}}#${CLUSTER_SHARED_VOLUME}#" \
    -e "s#{{[ ]*results_directory[ ]*}}#${RESULTS_DIRECTORY}#" \
    -e "s#{{[ ]*tmp_directory[ ]*}}#${TMP_DIRECTORY}#" \
    -e "s#{{[ ]*top_number_of_genes[ ]*}}#${TOP_NUMBER_OF_GENES}#" > ./run_dir/job-parameters.yml

# Print parameters / progress to the logs
echo "Running Samples Clustering Pipeline with the following parameters:"
cat ./run_dir/job-parameters.yml

# Update Python path
export PYTHONPATH='../src':$PYTHONPATH 

# Run the GP pipeline
python3 ../src/samples_clustering.py -run_directory ./run_dir -run_file job-parameters.yml && echo 'Job complete!'

echo "Output directory:"
ls -al $OUTPUT_DIR
