#!/bin/bash

ipynb=$1
out_ipynb=$2
out_ipynb_dir_dnax=$3
chrom=$4

stderr="${out_ipynb}-stderr"

papermill ${ipynb} ${out_ipynb} -p chrom "${chrom}" --stderr-file "${stderr}"
dx upload "${out_ipynb}" --path "${out_ipynb_dir_dnax}/${out_ipynb}" --parents
dx upload "${stderr}" --path "${out_ipynb_dir_dnax}/${stderr}" --parents
dx terminate $( hostname )
