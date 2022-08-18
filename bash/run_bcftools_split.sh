#!/bin/bash

export project=`dx pwd`

readonly script="bcftools_split.sh"
# Upload script to scripts/ directory, creating parent directory (scripts/) if needed
# dx upload ${script} --path scripts/ --parents

# Set up output directory
readonly out_dir="wes_450k_qc/data/01_split"
dx mkdir -p ${out_dir}

readonly chrom=21

run_split() {
  local _chrom=$1
  block=$2

  dx run swiss-army-knife \
  -iin="${project}scripts/${script}" \
  -icmd="bash ${script} ${chrom} ${block}" \
  --name="bcftools split c${_chrom} b${block}" \
  --instance-type "mem2_ssd1_v2_x8" \
  --destination="${project}${out_dir}" \
  -y \
  --priority "low"
}

# NOTE: Blocks are zero-indexed
run_split ${chrom} 3 # TEST RUN

# for block in {3..10}; do
#   run_split ${chrom} ${block}
# done
