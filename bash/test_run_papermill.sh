#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/barneyh/brava/ukb_wes_450k_qc"

## Job parameters
# instance_type="mem1_ssd1_v2_x72" # Very large
# instance_type="mem3_ssd1_v2_x32" # Large
instance_type="mem3_ssd1_v2_x16" # DEFAULT
# instance_type="mem1_ssd1_v2_x8" # DEFAULT
# instance_type="mem1_ssd1_v2_x2" # Small


# instance_count="64" # Very large
instance_count="32"
# instance_count="16" # Large
# instance_count="8" # Medium
# instance_count="4" # Small-mid


# Duration in minutes
duration="1000" # arbitrarily large, cost limit will automatically terminate if needed


# Cost limit (in GBP)
cost_limit="500"

chrom=$1

# ipynb="test_papermill_filter.ipynb"
# ipynb="test_papermill_simple.ipynb"
# ipynb="sample_qc_raw_vcf.ipynb"
# ipynb="papermill_filter_sample_qc.ipynb"
# ipynb_prefix="01_calc_call_rate_and_coverage"
# ipynb_prefix="test-01_calc_call_rate_and_coverage-ALTERNATE"
# ipynb_prefix="test-01_calc_call_rate_and_coverage"
# ipynb_prefix="test-02_hail_sample_qc"
# ipynb_prefix="test-04_final_filter_write_to_mt"
# ipynb_prefix="test-04_final_filter_write_pass_variants"
ipynb_prefix="test-04_final_filter_v2_write_and_export"
# ipynb_prefix="test-05_final_sample_stats"
# ipynb_prefix="test-05_final_variant_stats"
# ipynb_prefix="test-07_export_to_plink"


ipynb="${ipynb_prefix}.py"

ipynb_w_chrom="${ipynb_prefix}_c${chrom}.ipynb"
out_ipynb="timed-${ipynb_w_chrom}"

ipynb_dir_dnax="/notebooks/in"
out_ipynb_dir_dnax="/notebooks/out"
ipynb_dnax="${ipynb_dir_dnax}/${ipynb}"
ipynb_local="${WD}/python/ukb_wes_450k_qc/${ipynb}"

script="test_papermill.sh"

script_dir_dnax="/scripts/in"
script_dnax="${script_dir_dnax}/${script}"
script_local="${WD}/bash/${script}"


# Refresh script and ipynb with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${ipynb_local}" "${ipynb_dnax}"
upload_file "${script_local}" "${script_dnax}"


# Name of job
name="${ipynb_prefix}_c${chrom}-${instance_count}x"

dx run \
  dxjupyterlab_spark_cluster \
    --instance-type="${instance_type}" \
    --instance-count="${instance_count}" \
    -icmd="python3 /mnt/project${ipynb_dnax} --chrom ${chrom}" \
    --name="${name}" \
    --priority="high" \
    --yes \
    -iduration="${duration}" \
    -ifeature="HAIL" \
    --brief \
    --cost-limit="${cost_limit}"
