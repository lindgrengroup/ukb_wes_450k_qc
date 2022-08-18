#!/bin/bash

out=$1

file_list="file_list.txt"

n_cpu=$( grep -c ^processor /proc/cpuinfo )

ls -1 ./*vcf.gz | sort -Vk 1 > "${file_list}"

bcftools concat \
  --file-list "${file_list}" \
  --output-type z \
  --threads $(( n_cpu-1 )) \
  --output ${out}