#!/bin/bash

export project=`dx pwd`

readonly script="bcftools_count_variants.sh"
dx upload ${script} --path scripts/${script}

readonly chrom=21

for block in {0..10}; do
dx run swiss-army-knife \
  -iin="${project}scripts/${script}" \
  -icmd="bash ${script} ${chrom} ${block}" \
  --name="bcftools count variants c${chrom} b${block}" \
  --instance-type "mem2_ssd1_v2_x8" \
  --destination="${project}${out_dir}" \
  -y
done
