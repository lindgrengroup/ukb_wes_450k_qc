#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

## Job parameters
# instance_type="mem1_ssd1_v2_x2" # Small
# instance_type="mem1_ssd1_v2_x8" # DEFAULT
instance_type="mem1_ssd1_v2_x36" # Large
# instance_type="mem1_ssd1_v2_x72" # Very large

instance_count="32" # Large
# instance_count="4" # Medium

duration="240"

chrom=20

# ipynb="test_papermill_filter.ipynb"
# ipynb="test_papermill_simple.ipynb"
# ipynb="sample_qc_raw_vcf.ipynb"
# ipynb="papermill_filter_sample_qc.ipynb"
ipynb_prefix="test-01_calc_call_rate_and_coverage"
# ipynb_prefix="test-02_hail_sample_qc"
ipynb="${ipynb_prefix}.ipynb"

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
  -iin="${ipynb_dnax}" \
  -iin="${script_dnax}" \
  -icmd="bash ${script} ${ipynb} ${out_ipynb} ${out_ipynb_dir_dnax} ${chrom}" \
  --name="${name}" \
  --priority="low" \
  --yes \
  -iduration="${duration}" \
  -ifeature="HAIL-0.2.78" \
  --brief



