## code to prepare `nbm_block` dataset goes here

# this workflow depend on nbm_raw processed in NBM.R and the 2020 US Census Block
# I used an in house dataset here but this can be replaced by tigris
# or just going in the FTP of US census
# our internal package
library(cori.db)

get_census_block <- function() {
  con <- cori.db::connect_to_db("sch_census_tiger")
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  statement_census <- "select 
                            geoid20 as geoid_bl
                        from 
                            sch_census_tiger.source_tiger_2020_blocks"
  DBI::dbGetQuery(con, statement_census)
}

census_blocks <- get_census_block()

stopifnot(nrow(census_blocks) == 8180866)

library(duckdb)

# I worked with a peersistent db
# because I also like testing on duckdb cli
# and maybe cache some intermediary process
con <- dbConnect(duckdb(), dbdir = "nbm_block.duckdb")

DBI::dbCreateTable(con, "nbm_block", census_blocks)

nbm_cori1 <-  "create table staging (
                    frn char(10),
                    provider_id varchar(7),
                    location_id varchar(10),
                    brand_name text,
                    technology varchar(2),
                    max_advertised_download_speed integer,
                    max_advertised_upload_speed integer, 
                    low_latency boolean,
                    geoid_st varchar(2),
                    geoid_bl varchar(15),
                    geoid_co varchar(5));"

DBI::dbExecute(con, nbm_cori1)

# I used nbm_raw produced previoulsy
nbm_cori2 <- "
with filtered as (
select
	frn,
	provider_id,
	location_id,
	brand_name,
	technology,
	max_advertised_download_speed,
	max_advertised_upload_speed,
	low_latency,
    state_usps as geoid_st,
    geoid_bl,
	geoid_co
from
	read_parquet('nbm_raw/*/*/*/*.parquet')
where
	(max_advertised_download_speed = 0 AND
	max_advertised_upload_speed = 0) = false
    and low_latency = true and
    release = '2023-12-01'
)

insert into staging (frn, provider_id, location_id, brand_name, technology,
                     max_advertised_download_speed,
                     max_advertised_upload_speed,
                     low_latency, geoid_st,  geoid_bl, geoid_co)
select
	frn,
	provider_id,
	location_id,
	brand_name,
	technology,
	max_advertised_download_speed,
	max_advertised_upload_speed,
	low_latency,
	geoid_st,
    geoid_bl,
    geoid_co
from 
	filtered
where
	technology = 0
	or technology = 10
	or technology = 40
	or technology = 50
	or technology = 71
	or technology = 72;"

DBI::dbExecute(con, nbm_cori2)

DBI::dbDisconnect(con)

nbm_count1 <- "
alter table nbm_block
add column cnt_total_locations integer;
update
	nbm_block as t1
set
	cnt_total_locations = t2.cnt_total_locations
from
	(select
	geoid_bl,
	count(distinct location_id) as cnt_total_locations
from
	read_parquet('nbm_raw/*/*/*/*.parquet')
where release = '2023-12-01'
group by
	geoid_bl
) as t2
where
   t1.geoid_bl = t2.geoid_bl;"

DBI::dbExecute(con, nbm_cori2)

"
alter table nbm_block
add column cnt_bcat_locations integer;

update
	staging as t1
set 
	cnt_bcat_locations = t2.cnt_bcat_locations
from 
	(select 
	block_geoid,
	count(distinct location_id) as cnt_bcat_locations
	from 
		staging.bcat_raw_lowlat
	group by 
		block_geoid)  as t2
where    
	t1.geoid_bl = t2.block_geoid;"
