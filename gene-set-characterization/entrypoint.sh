#!/bin/bash

OUTPUT_DIR=/home/test/run_dir/results

# Ensure results folder exists
mkdir -p $OUTPUT_DIR

# Build up a parameters from our env
cat parameters.yml | sed -e "s#{{[ ]*analysis_method[ ]*}}#${ANALYSIS_METHOD}#" \
    -e "s#{{[ ]*gg_network_name_full_path[ ]*}}#${GG_NETWORK_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*pg_network_name_full_path[ ]*}}#${PG_NETWORK_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*spreadsheet_name_full_path[ ]*}}#${SPREADSHEET_NAME_FULL_PATH}#" \
    -e "s#{{[ ]*gene_names_map[ ]*}}#${GENE_NAMES_MAP}#" \
    -e "s#{{[ ]*results_directory[ ]*}}#${RESULTS_DIRECTORY}#" \
    -e "s#{{[ ]*rwr_max_iterations[ ]*}}#${RWR_MAX_ITERATIONS}#" \
    -e "s#{{[ ]*rwr_convergence_tolerence[ ]*}}#${RWR_CONVERGENCE_TOLERANCE}#" \
    -e "s#{{[ ]*rwr_restart_probability[ ]*}}#${RWR_RESTART_PROBABILITY}#" \
    -e "s#{{[ ]*k_space[ ]*}}#${K_SPACE}#" >> ./run_dir/job-parameters.yml

# Print parameters / progress to the logs
echo "Running Gene Set Characterization Pipeline with the following parameters:"
cat ./run_dir/job-parameters.yml

# Update Python path
export PYTHONPATH='./src':$PYTHONPATH

# Run the GP pipeline
python3 ../src/geneset_characterization.py -run_directory ./run_dir -run_file job-parameters.yml && echo 'Job complete!'

echo "Output directory:"
ls -al $OUTPUT_DIR
