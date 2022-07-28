#!/bin/bash

chrom=21
block=$1
out=$2

vcf_dir="/mnt/project/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)"
vcf="${vcf_dir}/ukb24068_c${chrom}_b${block}_v1.vcf.gz"

# Remove all variants with "RF" in FILTER field
bcftools annotate "${vcf}" \
  --remove "^FORMAT/GT,FORMAT/GQ,FORMAT/DP,FORMAT/AD" \
  --output-type u \
| bcftools view  \
  --exclude '%FILTER~"RF"' \
  --output-type z \
  --threads 2 \
  --output ${out}
