#!/bin/bash

readonly chrom=$1
readonly block=$2

#readonly vcf="/mnt/project/wes_450k_qc/data/01_split/ukb_wes_450k_split_chr${chrom}_b${block}"
readonly vcf="/mnt/project/wes_450k_qc/data/01_split-no_filter/ukb_wes_450k_split_chr${chrom}_b${block}.bcf.gz"

readonly var_ct=$( 
bcftools view \
  "${vcf}" \
  -H \
  -G \
  | wc -l 
)

echo "${vcf}"
echo "Variant count: ${var_ct}"
