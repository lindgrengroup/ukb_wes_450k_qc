#!/bin/bash

chroms=$1

raise_error() {
  # Prints error message to stderr
  >&2 echo -e "Error: $1. Exiting." && exit 1
}

bcftools_check() {
  #
  # Checks if bcftools command is available. If not, it points to my installation of bcftools v1.11
  #
  command -v bcftools \
    || raise_error "bcftools not found" 
}

get_eof_error() {
  #
  # Returns >0 number if VCF $1 is truncated
  #
  bcftools view -h $1 2>&1 | head | grep "No BGZF EOF marker" | wc -l
}

vcf_check() {
  #
  # Checks if VCF is valid.
  # Input: Path to VCF
  # 
  bcftools_check
  if [ ! -f $1 ]; then # check that VCF exists
    raise_error "$1 does not exist"
  elif [ ! -s $1 ]; then # check that VCF is not an empty file
    raise_error "$1 exists but is empty"
  elif [ $( get_eof_error $1 ) -gt 0 ]; then # check that VCF is not truncated
    raise_error "$1 may be truncated"
  fi
}

vcf_dir="/mnt/project/data/05_export_to_vcf"

# Split chroms string by comma and create list of chromosomes
IFS=',' read -r -a chrom_array <<< "${chroms}"

for chrom in "${chrom_array[@]}"; do
  
  vcf="${vcf_dir}/ukb_wes_450k.qced.chr${chrom}.vcf.gz"
  vcf_check "${vcf}" 

done


