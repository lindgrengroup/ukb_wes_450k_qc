#!/bin/bash

# "e" stops process if error occurs
# "u" throws error if variables are undefined
set -eu 

WD="/Users/nbaya/gms/lindgren/ukb_wes/ukb_wes_450k_qc"

script="cat_fam.sh"
script_local="${WD}/bash/${script}"
script_dnax="/scripts/${script}"

# Refresh script with latest version
source "${WD}/bash/dnax_utils.sh"
upload_file "${script_local}" "${script_dnax}"

## Job parameters
instance_type="mem1_ssd1_v2_x2" # DEFAULT
# instance_type="mem3_ssd1_v2_x4" # If higher mem is needed
destination="/data"


run_job() {

	
	dx run swiss-army-knife \
		--name "cat_fam" \
		-iin="${script_dnax}" \
		-icmd="bash ${script}" \
		--instance-type="${instance_type}" \
		--priority="low" \
		--destination="${destination}" \
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