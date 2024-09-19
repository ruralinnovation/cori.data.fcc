

"select * from read_parquet('s3://cori.data.fcc/nbm_block/*/*.parquet')
 where 
 combo_frn in (
 select combo_frn 
 from read_parquet('s3://cori.data.fcc/rel_combo_frn.parquet')
where frn = '0006945950'
 );"