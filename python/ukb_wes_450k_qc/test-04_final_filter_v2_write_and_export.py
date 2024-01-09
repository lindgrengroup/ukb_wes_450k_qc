import pyspark
import dxpy
import hail as hl
import pandas as pd
from math import ceil
import json
import os
import re
import glob
import argparse

my_database = dxpy.find_one_data_object(
    name="my_database", 
    project=dxpy.find_one_project()["id"]
)["id"]
database_dir = f'dnax://{my_database}'
sc = pyspark.SparkContext()
spark = pyspark.sql.SparkSession(sc)
hl.init(sc=sc, tmp_dir=f'{database_dir}/tmp/')

def install_dxda():
    binary_path = "https://github.com/dnanexus/dxda/releases/download/v0.6.0/dx-download-agent-linux"
    git_path = "https://github.com/dnanexus/dxda.git"

    # download git repo
    os.system(f"git clone {git_path} /home/dnanexus/dxda")

    # download binary
    os.system(f"wget {binary_path} -O /home/dnanexus/dx-download-agent")
    os.system("chmod +x /home/dnanexus/dx-download-agent")
    os.system("mv /home/dnanexus/dx-download-agent /usr/local/bin/dx-download-agent")

def download_files(path, chrom, blocks):
    # create manifest
    print(os.popen(f"python3 /home/dnanexus/dxda/scripts/create_manifest.py 'project-GBvkP10Jg8Jpy18FPjPByv29:{path}' --output_file 'ukb_wes_qc.manifest.json.bz2'").read())

    if blocks == "*":
        regex_pattern = f"^/.*ukb24068_c{chrom}_b.*"
    else:
        raise Exception("blocks != '*' is not implemented")

    print(os.popen(f"python3 /home/dnanexus/dxda/scripts/filter_manifest.py ukb_wes_qc.manifest.json.bz2 '{regex_pattern}'").read())
    # download files
    n_cpu=8 # increasing cpu may decrease performance past a point...
    print(os.popen(f"dx-download-agent download -num_threads={n_cpu} filtered_manifest.json.bz2").read())

def get_gnomad_vcf_path_for_regex(chrom, blocks):
    vcf_dir = "/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)"
    if blocks != '*':
        blocks = '('+'|'.join(map(str, blocks))+')'
        
    return f'{vcf_dir}/ukb24068_c{chrom}_b{blocks}_v1.vcf.gz'
def get_gnomad_vcf_path(chrom, blocks):
    vcf_dir = '/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)'
    if blocks != '*':
        blocks = '{'+','.join(map(str, blocks))+'}'
        
    path = f'{vcf_dir}/ukb24068_c{chrom}_b{blocks}_v1.vcf.gz'
    print(path)

    return path


def get_partitioned_chrom(chrom_w_suffix):
    """
    chrom_w_suffix should be of the form "{chr}-?of?", e.g. "8-1of4" for partition 1 of 4 in chromosome 8
    """
    chrom, suffix = chrom_w_suffix.split('-')
    assert chrom in list(map(str, range(1,23)))+['X','Y'], "chrom must be in  {1-22, X, Y}"
    part_idx, total_parts = map(int, suffix.split('of'))
    assert (part_idx>=1) & (part_idx<=total_parts)
    
    total_vcfs = len(hl.hadoop_ls(get_gnomad_vcf_path(chrom=chrom, blocks="*")))
    
    part_size = ceil(total_vcfs/total_parts)
    
    start_idx = (part_idx-1)*part_size
    stop_idx = min((part_idx)*part_size-1, total_vcfs-1)
    
    return get_gnomad_vcf_path(chrom, blocks=range(start_idx, stop_idx+1))
    
def import_single_chrom_vcf(chrom, blocks = '*'):
    if 'of' in str(chrom):
        # Get chunk of chromosome
        vcf_path = get_partitioned_chrom(chrom_w_suffix=chrom)
    else:
        vcf_path = get_gnomad_vcf_path(chrom=chrom, blocks=blocks)

        #install_dxda()
        #download_files("/Bulk/Exome sequences_Alternative exome processing/Exome variant call files (gnomAD) (VCFs)", chrom, blocks)

        vcf_path = "/mnt/project" + vcf_path
    
    return hl.import_vcf(
        ["file://" + file for file in glob.glob(vcf_path)], 
        force_bgz=True,
        reference_genome='GRCh38'
    )

def get_adj_expr(
    gt_expr: hl.expr.CallExpression,
    gq_expr: hl.expr.Int32Expression,
    dp_expr: hl.expr.Int32Expression,
    ad_expr: hl.expr.ArrayNumericExpression,
    adj_gq: int = 20,
    adj_dp: int = 10,
    adj_ab: float = 0.2,
    haploid_adj_dp: int = 5,
) -> hl.expr.BooleanExpression:
    """
    Get adj genotype annotation.

    Defaults correspond to gnomAD values.
    """
    return (
        (gq_expr >= adj_gq)
        & hl.cond(gt_expr.is_haploid(), dp_expr >= haploid_adj_dp, dp_expr >= adj_dp)
        & (
            hl.case()
            .when(~gt_expr.is_het(), True)
            .when(gt_expr.is_het_ref(), ad_expr[gt_expr[1]] / dp_expr >= adj_ab)
            .default(
                (ad_expr[gt_expr[0]] / dp_expr >= adj_ab)
                & (ad_expr[gt_expr[1]] / dp_expr >= adj_ab)
            )
        )
    )

def annotate_adj(
    mt: hl.MatrixTable,
    adj_gq: int = 20,
    adj_dp: int = 10,
    adj_ab: float = 0.2,
    haploid_adj_dp: int = 5,
) -> hl.MatrixTable:
    """
    Annotate genotypes with adj criteria (assumes diploid).

    Defaults correspond to gnomAD values.
    """
    return mt.annotate_entries(
        adj=get_adj_expr(
            mt.GT, mt.GQ, mt.DP, mt.AD, adj_gq, adj_dp, adj_ab, haploid_adj_dp
        )
    )
    
def filter_to_adj(mt: hl.MatrixTable) -> hl.MatrixTable:
    """Filter genotypes to adj criteria."""
    if "adj" not in list(mt.entry):
        mt = annotate_adj(mt)
    mt = mt.filter_entries(mt.adj)
    return mt.drop(mt.adj)

def get_mad_threshold_tsv_fname(n_mads, classification):
    return f'ukb_wes_450k.mad_threshold.nmad_{n_mads}.popclass_{classification}.tsv.gz'

def get_pass_mad_threshold_expr(mt, n_mads='4', classification='strict'):
    mad_fname = get_mad_threshold_tsv_fname(n_mads=n_mads, classification=classification)
    mad_path = f'file:///mnt/project/ukb_wes_450k_qc/data/03_mad_threshold/{mad_fname}'
    print(mad_path)
    mad_ht = hl.import_table(
        mad_path, 
        types={
            's': hl.tstr, 
            'pass': hl.tbool
        },
        key='s',
        force=True
    )
    return mad_ht[mt.s]['pass']

def get_final_filter_mt_path(chrom):
    return f'{database_dir}/04_final_filter_v2_write_to_mt/ukb_wes_450k.qced.chr{chrom}.mt'

def export_file(path, out_folder):
    dxpy.upload_local_file(
        filename=path,
        name=path.split('/')[-1],
        folder=out_folder,
        parents=True
    )

def final_filter(mt):
    mt = mt.filter_rows(hl.len(mt.filters)==0)
    mt = hl.variant_qc(mt)
    mt = annotate_adj(mt)
    mt = filter_to_adj(mt)
    pass_mad_threshold_expr = get_pass_mad_threshold_expr(mt, n_mads='4', classification='strict')
    mt = mt.annotate_cols(pass_mad_filter=pass_mad_threshold_expr)
    return mt
   
def main(chrom):
    mt_raw = import_single_chrom_vcf(chrom=chrom)
    mt_qced = final_filter(mt_raw)

    mt_qced.write(get_final_filter_mt_path(chrom))
        
    mt = mt.annotate_cols(gq = hl.agg.stats(mt.GQ), dp = hl.agg.stats(mt.DP))
    mt = hl.sample_qc(mt, name='sample_qc')

    INITIAL_SAMPLE_QC_FILE = f'03_chr{chrom}_initial_sample_qc.tsv.bgz'
    mt.cols().select('sample_qc', 'gq', 'dp').flatten().export(INITIAL_SAMPLE_QC_FILE)

    os.system('hdfs dfs -get ./*.tsv.bgz .')

    export_file(
        path=INITIAL_SAMPLE_QC_FILE, 
        out_folder='/Barney/qc/03_initial_sample/'
    )

if __name__=='__main__':

    parser = argparse.ArgumentParser(description="Process some integers.")
    parser.add_argument('--chrom', required=True, help='Chromosome number')

    args = parser.parse_args()
    main(chrom=args.chrom)
