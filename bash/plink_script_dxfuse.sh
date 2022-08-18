#!/bin/bash

readonly chrom=$1
readonly out="ukb_wes_450k_simple_qc_chr${chrom}"

plink \
  --bfile "/mnt/project/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - interim 450k release/ukb23149_c${chrom}_b0_v1" \
  --geno 0.02 \
  --mac 2 \
  --hwe 1e-6 \
  --make-just-bim \
  --out ${out}
