#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

script_prefix="head_vcf"
script="${script_prefix}.sh"
script_local="${WD}/bash/${script}"
script_dnax="/scripts/${script}"

# Refresh script with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${script_local}" "${script_dnax}"

## Job parameters
instance_type="mem1_ssd1_v2_x2" # DEFAULT
# instance_type="mem3_ssd1_v2_x4" # If higher mem is needed

# chroms="1-1of4,1-2of4,1-3of4,2,3,4,5,6,7,8-1of2,8-2of2,9,10"
chroms="11,12,13,14,15,16-1of2,16-2of2,17,18,19,20,21,22,X"

cmd="bash ${script} ${chroms}"


run_job() {

	dx run swiss-army-knife \
		--name "${script_prefix}-c${chroms}" \
		-iin="${script_dnax}" \
		-icmd="${cmd}" \
		--instance-type="${instance_type}" \
		--priority="low" \
		-y \
		--brief > /dev/null
	
}

# max_tasks=8
# i=0
# (
# for block in {0..399}; do 
#    ((i=i%max_tasks)); ((i++==0)) && wait
#    run_job ${block} & 
# done
# )

run_job