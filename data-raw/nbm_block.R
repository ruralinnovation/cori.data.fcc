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

DBI::dbWriteTable(con, "nbm_block", census_blocks)

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

DBI::dbExecute(con, nbm_count1)

# test tes default
nbm_count2 <- "
alter table nbm_block
add column cnt_cori_locations integer;

update
	nbm_block as t1
set 
	cnt_cori_locations = t2.cnt_cori_locations
from 
	(select 
	geoid_bl,
	count(distinct location_id) as cnt_cori_locations
	from 
		staging
	group by 
		geoid_bl)  as t2
where    
	t1.geoid_bl = t2.geoid_bl;"

# some could be NA, case census block 100 water? 
"update nbm_block set cnt_total_locations = 0 where cnt_total_locations is null;"
"update nbm_block set cnt_cori_locations = 0 where cnt_cori_locations is null;"


"alter table nbm_block
add column cnt_fiber_locations integer,
add column cnt_25_3 integer,
add column cnt_100_20 integer,
add column cnt_100_100 integer;

update
	nbm_block as t1
set 
	cnt_fiber_locations = t2.cnt_fiber_locations,
	cnt_25_3 = t2.cnt_25_3,
	cnt_100_20 = t2.cnt_100_20,
	cnt_100_100 = t2.cnt_100_100
	

from(
	select 
		geoid_bl,
		count(distinct case when technology = 50 then location_id end) as cnt_fiber_locations,
		count(distinct case when 
			(max_advertised_download_speed >= 25 and max_advertised_upload_speed >= 3) 
			              then location_id end) as cnt_25_3,
		count(distinct case when 
			(max_advertised_download_speed >= 100 and max_advertised_upload_speed >= 20) 
			              then location_id end) as cnt_100_20,
		count(distinct case when 
			(max_advertised_download_speed >= 100 and max_advertised_upload_speed >= 100) 
			              then location_id end) as cnt_100_100
	from 
		staging
	group by 
		geoid_bl) as t2
where    
	t1.geoid_bl = t2.geoid;



-- update staging.block_bcat set cnt_fiber_locations = 0
-- where cnt_fiber_locations is null and cnt_total_locations is not null;  
-- update  staging.block_bcat set cnt_25_3 = 0
-- where cnt_25_3 is null and cnt_total_locations is not null;
-- update staging.block_bcat set cnt_100_20 = 0
-- where cnt_100_20 is null and cnt_total_locations is not null;
-- update staging.block_bcat set cnt_100_100 = 0
-- where cnt_100_100 is null and cnt_total_locations is not null;"