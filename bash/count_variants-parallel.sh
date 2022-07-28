#!/bin/bash

# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}

count_variants() {
	local _block=$1

	ct=$( 
		bcftools view "/mnt/project/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)/ukb24068_c${chrom}_b${_block}_v1.vcf.gz" \
		-H \
		-G \
		| wc -l 
	)

	echo $ct > block${_block}.txt
}

chrom=21
n_blocks=$( dx ls -l "/mnt/project/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)/ukb24068_c${chrom}_*_v1.vcf.gz" | wc -l )

N=4
open_sem $N
# for block in {0..$(( n_blocks-1 ))}; do
echo "n_blocks: ${n_blocks}"
for block in {0..10}; do
    run_with_lock count_variants $block
done

total=$( awk '{sum+=$1;} END{print sum;}' block${_block}.txt );
echo "chr${chrom} ${total}"

rm block*.txt