#!/bin/bash 

bfile="ukb_array_pruned"
out="test-ukb_array"

createSparseGRM.R       \
    --plinkFile="${bfile}" \
    --nThreads=72  \
    --outputPrefix="${out}"       \
    --numRandomMarkerforSparseKin=5000      \
    --relatednessCutoff=0.05