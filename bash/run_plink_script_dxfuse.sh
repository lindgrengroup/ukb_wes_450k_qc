#!/bin/bash

export project=`dx pwd`

readonly chrom=21

dx run swiss-army-knife \
	-iin="${project}scripts/plink_script_dxfuse.sh" \
	-icmd="bash plink_script_dxfuse.sh ${chrom}" \
	--name="dxfuse plink variant filter" \
	--instance-type "mem1_ssd1_v2_x8" \
	--destination="${project}results/" \
	-y

