import pyspark
import dxpy
import hail as hl

my_database = dxpy.find_one_data_object(name="my_database")["id"]
database_dir = f'dnax://{my_database}'
sc = pyspark.SparkContext()
spark = pyspark.sql.SparkSession(sc)
hl.init(sc=sc, tmp_dir=f'{database_dir}/tmp/')

chrom = 21
block = 10

vcf_dir = 'file:///mnt/project/Bulk/Exome sequences/Population level exome OQFE variants, pVCF format - interim 450k release'
vcf_path=f'{vcf_dir}/ukb23148_c{chrom}_b{block}_v1.vcf.gz'

mt = hl.import_vcf(
	vcf_path, 
	force=True, 
	reference_genome='GRCh38'
)

mt.write(f'{database_dir}/ukb_wes_450k_c{chrom}_b{block}.raw.mt')

