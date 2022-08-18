#!/bin/bash

chrom=21
block=$1
out=$2

vcf_dir="/mnt/project/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)"
vcf="${vcf_dir}/ukb24068_c${chrom}_b${block}_v1.vcf.gz"

# Remove all variants with "RF" in FILTER field
bcftools annotate "${vcf}" \
  --remove '^FORMAT/GT,FORMAT/GQ,FORMAT/DP,FORMAT/AD' \
  --output-type u \
| bcftools view  \
  --exclude '%FILTER~"RF"' \
  --output-type u \
| bcftools filter \
  --include 'FMT/DP>=10 & FMT/GQ>=20 & (GT!="het" | (GT="het" & (FMT/AD[:0]/DP > 0.2 & FMT/AD[:1]/DP > 0.2)))' \
  --set-GTs "." \
  --output-type z \
  --threads 2 \
  --output ${out}