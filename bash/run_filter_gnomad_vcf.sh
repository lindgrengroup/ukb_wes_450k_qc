#!/bin/bash

set -u # throws error if variables are undefined

script="filter_gnomad_vcf.sh"
script_local="/Users/nbaya/Downloads/dnanexus_test/${script}"
script_dnax="/scripts/${script}"

# Refresh script with latest version
file_ct=$( dx ls -l --obj "${script_dnax}" 2> /dev/null | wc -l )
if [ ${file_ct} -lt 1 ]; then
	dx mv "${script_dnax}" "${script_dnax}-tmp" \
	&& dx upload "${script_local}" --path "${script_dnax}" --brief > /dev/null \
	&& dx rm --force "${script_dnax}-tmp"
else
	dx upload "${script_local}" --path "${script_dnax}" --brief > /dev/null
fi

## Job parameters
instance_type="mem1_ssd1_v2_x2" # DEFAULT
# instance_type="mem3_ssd1_v2_x4" # If higher mem is needed
destination="/data/01_prelim_variant_filter"


run_job() {
	block=$1

	out="ukb_wes_450k_c21_b${block}.filter_rf.vcf.gz"

	ct=$( dx ls -l --obj "${destination}/${out}" 2> /dev/null | wc -l )

	if [ $ct -lt 1 ]; then
		dx run swiss-army-knife \
			--name "filter_vcf_c21_b${block}" \
			-iin="${script_dnax}" \
			-icmd="bash ${script} ${block} ${out}" \
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