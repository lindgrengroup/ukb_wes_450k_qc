#!/bin/bash

readonly chrom=$1
readonly block=$2

readonly out="ukb_wes_450k_split_chr${chrom}_b${block}"

readonly in="/mnt/project/Bulk/Exome sequences/Population level exome OQFE variants, pVCF format - interim 450k release/ukb23148_c${chrom}_b${block}_v1.vcf.gz"
readonly fasta="/mnt/project/resources/GRCh38_full_analysis_set_plus_decoy_hla.fa"

# Piped bcftools commands:
# 1. Remove sites with >9 alt alleles (equivalent to >10 total alleles, 9 alt + 1 ref)
# 2. Split multiallelic sites, left-align
 bcftools view \
   "${in}" \
   -M 10 \
   -Ou \
 | bcftools norm \
   -f ${fasta} \
   -m \
   -any \
   --threads 7 \
   -o ${out} \
   -Oz 

# Split but without removing sites based on number of alt alleles
# bcftools norm \
#   "${in}" \
#   -f ${fasta} \
#   -m \
#   -any \
#   --threads 7 \
#   -Ob \
#   -o "${out}.bcf.gz"
