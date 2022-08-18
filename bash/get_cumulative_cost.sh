#!/bin/bash
#
# Get cumulative cost of all jobs in given date range
# Date format options: 
# 1) YYYY-MM-DD 
# 2) Use negative numbers to indicate time period in the past suffixed by s, m, h, d, w, M or y to indicate seconds, minutes, etc. 
#    For example, "-2" corresponds to two days ago
#
# Options: Specify user

set -u 

after=$1
before=$2

random_string=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '' )
job_list_path="/tmp/dnax_jobs_${after}_${before}.txt"
num_results=100000 # arbitrarily large number to ensure we get all jobs in the range


dx find jobs \
  --created-after ${after} \
  --created-before ${before} \
  --brief \
  --num-results ${num_results} > ${job_list_path}

job_price_path="/tmp/dnax_prices_${after}_${before}.txt"

n_jobs=$( wc -l ${job_list_path} )

if [ ${n_jobs} -eq 0 ]; then
	echo "Number of jobs is zero." && exit 0
elif [ ! -f ${job_price_path} ] || [ $( wc -l ${job_price_path} ) -ne ${n_jobs} ]; then
	while read job_id; do
		dx describe ${job_id} --json 2> /dev/null | jq -r '.totalPrice' >> ${job_price_path}
	done < ${job_list_path}
fi

awk '{sum+=$1}END{print sum}' ${job_price_path}
# rm ${job_list_path}