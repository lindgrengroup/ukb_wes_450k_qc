#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

script_prefix="concat_vcf_parts"
script="${script_prefix}.sh"
script_local="${WD}/bash/${script}"
script_dnax="/scripts/${script}"

# Refresh script with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${script_local}" "${script_dnax}"

## Job parameters
# instance_type="mem1_ssd1_v2_x2" # DEFAULT
# instance_type="mem3_ssd1_v2_x4" # If higher mem is needed
instance_type="mem3_ssd1_v2_x8" # If higher mem is needed

chrom=$1
max_parts=$2

cmd="bash ${script} ${chrom} ${max_parts}"

destination="/data/05_export_to_vcf"

run_job() {

	dx run swiss-army-knife \
		--name "${script_prefix}-c${chrom}" \
		-iin="${script_dnax}" \
		-icmd="${cmd}" \
		--instance-type="${instance_type}" \
		--priority="low" \
		--destination="${destination}" \
		-y \
		--brief > /dev/null
	
}

run_job