#!/bin/bash

chrom=$1
block=$2
out=$3

vcf_dir="/mnt/project/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)"
vcf="${vcf_dir}/ukb24068_c${chrom}_b${block}_v1.vcf.gz"

# Samples to keep
pass_samples="/mnt/project/data/04_final_filter/ukb_wes_450k.pass_samples.tsv.gz"


# 1. Keep samples that pass QC
# - Note: Exclude header of list of samples (tail -n+2) [TEMPORARY]
# 2. Keep genotypes if:
# - DP >= 10
# - GQ >= 20
# - minor allele balance > 0.2 for alternate alleles for heterozygous genotypes
bcftools view "${vcf}" \
  --samples-file <( zcat "${pass_samples}" | tail -n+2 ) \
  --output-type u \
| bcftools filter \
  --include 'FMT/DP>=10 & FMT/GQ>=20 & (GT!="het" | (GT="het" & (FMT/AD[:0]/DP > 0.2 & FMT/AD[:1]/DP > 0.2)))' \
  --set-GTs "." \
  --output-type z \
  --threads 7 \
  --output ${out}