#!/bin/bash

chrom=$1
max_parts=$2

vcf_dir="/mnt/project/data/05_export_to_vcf"

vcf_list="tmp_vcf_list.txt"

for part in `seq 1 ${max_parts}`; do
  vcf="${vcf_dir}/ukb_wes_450k.qced.chr${chrom}-${part}of${max_parts}.vcf.gz"
  echo "${vcf}" >> "${vcf_list}"
done

bcftools concat \
  --file-list "${vcf_list}" \
  --threads 7 \
  --output-type z \
  --output "ukb_wes_450k.qced.chr${chrom}.vcf.gz"

rm "${vcf_list}"