#!/bin/bash
#
# Get cumulative cost of all jobs in given date range
# Date format options: 
# 1) YYYY-MM-DD 
# 2) Use negative numbers to indicate time period in the past suffixed by s, m, h, d, w, M or y to indicate seconds, minutes, etc. 
#    For example, "-2" corresponds to two days ago
#
# Note: To load jq on BMRC, use `module load jq`


# random_string=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '' )
all_job_ids_path="/tmp/dnax_all_job_ids.txt"
num_results=100000 # arbitrarily large number to ensure we get all jobs in the range


dx find jobs \
  --created-after="2000-01-01" \
  --all-projects \
  --brief \
  --num-results ${num_results} 2> /dev/null > ${all_job_ids_path}

n_jobs=$( cat ${all_job_ids_path} | wc -l )

all_jobs_path="/tmp/dnax_all_jobs.tsv"

if [ ${n_jobs} -eq 0 ]; then
	echo "Number of jobs is zero." && exit 0
elif [ ! -f ${all_jobs_path} ] || [ $( cat ${all_jobs_path} | wc -l ) -ne ${n_jobs} ]; then
	while read job_id; do
		dx describe ${job_id} --json \
		| jq -r '[ .project,.launchedBy,.instanceType,.startedRunning,.stoppedRunning,.totalPrice ] | @tsv' >> ${all_jobs_path}
	done < ${all_job_ids_path}
fi

echo "Job info saved to: ${all_jobs_path}"