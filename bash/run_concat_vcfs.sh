#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

script="concat_vcfs.sh"
script_local="${WD}/bash/${script}"
script_dnax="/scripts/${script}"

# Refresh script with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${script_local}" "${script_dnax}"

## Job parameters
instance_type="mem1_ssd1_v2_x2" # DEFAULT
# instance_type="mem3_ssd1_v2_x4" # If higher mem is needed
destination="/data/01_prelim_variant_filter"


run_job() {
	block=$1

	out="ukb_wes_450k_c21_b${block}.filter_rf_gt.vcf.gz"

	ct=$( dx ls -l --obj "${destination}/${out}" 2> /dev/null | wc -l )

	if [ $ct -lt 1 ]; then
		dx run swiss-army-knife \
			--name "concat_c21" \
			-iin="${script_dnax}" \
			
			-icmd="bash ${script} ${out}" \
			--instance-type="${instance_type}" \
			--destination="${destination}" \
			-y \
			--brief > /dev/null
	fi
}

max_tasks=8
i=0
(
for block in {1..399}; do 
   ((i=i%max_tasks)); ((i++==0)) && wait
   run_job ${block} & 
done
)

# run_job 0