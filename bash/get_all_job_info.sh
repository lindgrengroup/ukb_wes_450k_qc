#!/bin/bash
#
# Get cumulative cost of all jobs ever
#
# Note: To load jq on BMRC, use `module load jq`

module load jq

# random_string=$( tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '' )
all_job_ids_path="/tmp/dnax_all_job_ids.txt"
num_results=100000 # arbitrarily large number to ensure we get all jobs in the date range


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
  run_job() {
    local _task_id=$1
    local _row_idx=$2
    local _job_id=$( sed "${_row_idx}q;d" "${all_job_ids_path}-${_task_id}" )
    echo ${_job_id}

    dx describe ${_job_id} --json \
      | jq -r '[ .project,.launchedBy,.instanceType,.executableName,.startedRunning,.stoppedRunning,.totalPrice ] | @tsv' 2> /dev/null >> "${all_jobs_path}-${_task_id}"
  }

  if [ -f ${all_jobs_path} ]; then
    rm -f ${all_jobs_path}*
  fi

  max_tasks=16
  i=0

  for task_id in `seq 1 ${max_tasks}`; do
    cp ${all_job_ids_path} "${all_job_ids_path}-${task_id}"
  done

  (
  for row_idx in `seq 1 ${n_jobs}`; do
    ((i=i%max_tasks)); ((i++==0)) && wait
    run_job ${i} ${row_idx} &
  done
  )

  #for row_idx in `seq 1 ${n_rows}`; do
  #  run_job $(( row_idx % max_tasks )) ${row_idx}
  #done

  cat "${all_jobs_path}-"* > ${all_jobs_path}
  rm -f "${all_jobs_path}-"*

fi

echo "Job info saved to: ${all_jobs_path}"