#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

script="test_papermill.ipynb"
script_local="${WD}/python/ukb_wes_450k_qc/${script}"
script_dnax="/notebooks/${script}"
out_script_dnax="/notebooks/output-timed-${script}"

# Refresh script with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${script_local}" "${script_dnax}"


## Job parameters
# instance_type="mem1_ssd1_v2_x8" # DEFAULT
instance_type="mem1_ssd1_v2_x16"
instance_count="100"
name="papermill-timed-${instance_count}x"
dnax_cmd="papermill ${script_dnax} ${out_script_dnax}"
duration="30"

dx run \
  dxjupyterlab_spark_cluster \
  --instance-type="${instance_type}" \
  --instance-count="${instance_count}" \
  -iin="${script_dnax}" \
  -icmd="${dnax_cmd}" \
  --name="${name}" \
  --priority="low" \
  --yes \
  -iduration="${duration}" \
  -ifeature="HAIL-0.2.78" \
  --brief

