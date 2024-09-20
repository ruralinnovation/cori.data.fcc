## code to prepare `nbm_block` dataset goes here

# this workflow depend on nbm_raw processed in NBM.R and the 2020 US Census Block
# I used an in house dataset here but this can be replaced by tigris
# or just going in the FTP of US census
# our internal package
library(cori.db)
library(duckdb)

get_census_block <- function() {
  con <- cori.db::connect_to_db("sch_census_tiger")
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  statement_census <- "select 
                            geoid20 as geoid_bl
                        from 
                            sch_census_tiger.source_tiger_2020_blocks"
  message(sprintf("Starting to get Census Block: %s", Sys.time()))
  DBI::dbGetQuery(con, statement_census)
}

census_blocks <- get_census_block()


stopifnot(nrow(census_blocks) == 8180866)

# I worked with a persistent db
# because I also like testing on duckdb cli
# and maybe cache some intermediary process
con <- dbConnect(duckdb(), dbdir = "nbm_block.duckdb")

release <- "2023-12-01"

message(sprintf("Release used: %s", release))

DBI::dbWriteTable(con, "nbm_block", census_blocks)

set_release <- sprintf("alter table nbm_block
					   add column release date;
					   update nbm_block set release = '%s'"
					   , release)

DBI::dbExecute(con, set_release)

message(sprintf("Creating a filtered table: %s", Sys.time()))

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

# the last release is '2023-12-01'

# I used nbm_raw produced previoulsy
nbm_cori2 <- sprintf("
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
	-- here is the release
    release = '%s'
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
	or technology = 72;", release)

DBI::dbExecute(con, nbm_cori2)


message(sprintf("Starting adding count of locations; %s", Sys.time()))

nbm_count1 <- sprintf("
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
where release = '%s'
group by
	geoid_bl
) as t2
where
   t1.geoid_bl = t2.geoid_bl;", release)

DBI::dbExecute(con, nbm_count1)

# test tes default
nbm_count2 <- "
alter table nbm_block
add column cnt_bead_locations integer;

update
	nbm_block as t1
set 
	cnt_bead_locations = t2.cnt_bead_locations
from 
	(select 
	geoid_bl,
	count(distinct location_id) as cnt_bead_locations
	from 
		staging
	group by 
		geoid_bl)  as t2
where    
	t1.geoid_bl = t2.geoid_bl;"

DBI::dbExecute(con, nbm_count2)

stopifnot(ncol(DBI::dbGetQuery(con, "select * from nbm_block limit 10")) ==  4L)

nbm_count3 <-
	"alter table nbm_block add column cnt_fiber_locations integer;
	 alter table nbm_block add column cnt_25_3 integer;
	 alter table nbm_block add column cnt_100_20 integer;
	 alter table nbm_block add column cnt_100_100 integer;

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
		t1.geoid_bl = t2.geoid_bl;"

DBI::dbExecute(con, nbm_count3)

# duckdb support only one alter command per statement
# this part merit a comment: we are seting 0 for all the counts
# when we have at least one location recorded at the block
# if the block has no location we let null/NA

nbm_count4 <- "
	update nbm_block set cnt_bead_locations = 0
	where cnt_bead_locations is null and cnt_total_locations is not null;
	update nbm_block set cnt_fiber_locations = 0
	where cnt_fiber_locations is null and cnt_total_locations is not null;
	update nbm_block set cnt_25_3 = 0
	where cnt_25_3 is null and cnt_total_locations is not null;
	update nbm_block set cnt_100_20 = 0
	where cnt_100_20 is null and cnt_total_locations is not null;
	update nbm_block set cnt_100_100 = 0
	where cnt_100_100 is null and cnt_total_locations is not null;"

DBI::dbExecute(con, nbm_count4)

nbm_count5 <- "alter table nbm_block add column cnt_copper_locations integer;
	alter table nbm_block add column cnt_cable_locations integer;
	alter table nbm_block add column cnt_other_locations integer;
	alter table nbm_block add column cnt_licensed_fixed_wireless_locations integer;
	alter table nbm_block add column cnt_LBR_fixed_wireless_locations integer;
	alter table nbm_block add column cnt_terrestrial_locations integer;

with temp as (select 
			geoid_bl,
			count(distinct case when technology = '10' then location_id end) as cnt_copper_locations,
			count(distinct case when technology = '40' then location_id end) as cnt_cable_locations,
			count(distinct case when technology = '0' then location_id end) as cnt_other_locations,
			count(distinct case when technology = '71' then location_id end) as cnt_licensed_fixed_wireless_locations,
			count(distinct case when technology = '72' then location_id end) as cnt_LBR_fixed_wireless_locations,
			count(distinct case when 
					technology in ('10', '40', '50', '70', '71', '72') 
					then location_id end) as cnt_terrestrial_locations
		from 
			staging group by geoid_bl)

	update
		nbm_block as t1
	set 
		cnt_copper_locations = t2.cnt_copper_locations,
		cnt_cable_locations = t2.cnt_cable_locations,
		cnt_other_locations = t2.cnt_other_locations,
		cnt_licensed_fixed_wireless_locations = t2.cnt_licensed_fixed_wireless_locations,
		cnt_LBR_fixed_wireless_locations = t2.cnt_LBR_fixed_wireless_locations,
		cnt_terrestrial_locations = t2.cnt_terrestrial_locations
	from temp as t2
	where    
		t1.geoid_bl = t2.geoid_bl;"

DBI::dbExecute(con, nbm_count5)

nbm_count5b <- sprintf(
	"alter table nbm_block add column cnt_unlicensed_fixed_wireless_locations integer;

	update
		nbm_block as t1
	set 
		cnt_unlicensed_fixed_wireless_locations = t2.cnt_unlicensed_fixed_wireless_locations
	from(
		select 
			geoid_bl,
			count(distinct case when technology = '70' then location_id end) as cnt_unlicensed_fixed_wireless_locations
		from 
			read_parquet('nbm_raw/*/*/*/*.parquet')
			where release = '%s'
		group by
			geoid_bl) as t2
			
	where t1.geoid_bl = t2.geoid_bl;", release)

DBI::dbExecute(con, nbm_count5b)

nbm_count6 <- "
	update nbm_block set cnt_copper_locations = 0
	where cnt_copper_locations is null and cnt_total_locations is not null;

	update nbm_block set cnt_cable_locations = 0
	where cnt_cable_locations is null and cnt_total_locations is not null;

	update nbm_block set cnt_other_locations = 0
	where cnt_other_locations is null and cnt_total_locations is not null;

	update nbm_block set cnt_unlicensed_fixed_wireless_locations = 0
	where cnt_unlicensed_fixed_wireless_locations is null and cnt_total_locations is not null;

	update nbm_block set cnt_licensed_fixed_wireless_locations = 0
	where cnt_licensed_fixed_wireless_locations is null and cnt_total_locations is not null;
	
	update nbm_block set cnt_LBR_fixed_wireless_locations = 0
	where cnt_LBR_fixed_wireless_locations is null and cnt_total_locations is not null;

	update nbm_block set cnt_terrestrial_locations = 0
	where cnt_terrestrial_locations is null and cnt_total_locations is not null;
	"

DBI::dbExecute(con, nbm_count6)

message(sprintf("Starting create combo frn and relation table: %s", Sys.time()))

combo_frn <-
	"alter table nbm_block
	add column array_frn varchar[];

	alter table nbm_block
	add column combo_frn uint64;

	with combo as (
	select 
		geoid_bl, 
		array_agg(distinct frn order by frn) as array_frn, 
		hash(array_frn) as combo_frn 
	from staging 
	group by geoid_bl
	)

	update nbm_block as t1
	set 
		array_frn = t2.array_frn,
		combo_frn = t2.combo_frn
	from
		combo as t2
	where t1.geoid_bl = t2.geoid_bl;"

DBI::dbExecute(con, combo_frn)

rel_combo_frn <- "create table rel_combo_frn (
					frn varchar(10),
					combo_frn uint64,
					primary key (frn, combo_frn)
					);

				  insert into rel_combo_frn
					select
						distinct unnest(array_frn) as frn,
						combo_frn
					from
						nbm_block;"

DBI::dbExecute(con, rel_combo_frn)

frn_count <- "
	alter table nbm_block add column cnt_distcint_frn integer;

	update
		nbm_block as t1
	set 
		cnt_distcint_frn = t2.cnt_distcint_frn

	from (select 
			geoid_bl,
			count(distinct frn) as cnt_distcint_frn 
		from 
			staging
		group by 
			geoid_bl) as t2
	where    
		t1.geoid_bl = t2.geoid_bl;	"

DBI::dbExecute(con, frn_count)

message(sprintf("Starting creating utiliies columns: %s", Sys.time()))

states <-
"create temp table us_states (
    state_abbr varchar(2) primary key,
    geoid_st char(2) not null
);

insert into us_states (state_abbr, geoid_st) values
('AL', '01'),  -- Alabama
('AK', '02'),  -- Alaska
('AS', '60'),  -- American Samoa
('AZ', '04'),  -- Arizona
('AR', '05'),  -- Arkansas
('CA', '06'),  -- California
('CO', '08'),  -- Colorado
('CT', '09'),  -- Connecticut
('DE', '10'),  -- Delaware
('DC', '11'),  -- District of Columbia
('FL', '12'),  -- Florida
('GA', '13'),  -- Georgia
('GU', '66'),  -- Guam
('HI', '15'),  -- Hawaii
('ID', '16'),  -- Idaho
('IL', '17'),  -- Illinois
('IN', '18'),  -- Indiana
('IA', '19'),  -- Iowa
('KS', '20'),  -- Kansas
('KY', '21'),  -- Kentucky
('LA', '22'),  -- Louisiana
('ME', '23'),  -- Maine
('MD', '24'),  -- Maryland
('MA', '25'),  -- Massachusetts
('MI', '26'),  -- Michigan
('MN', '27'),  -- Minnesota
('MS', '28'),  -- Mississippi
('MO', '29'),  -- Missouri
('MT', '30'),  -- Montana
('NE', '31'),  -- Nebraska
('NV', '32'),  -- Nevada
('NH', '33'),  -- New Hampshire
('NJ', '34'),  -- New Jersey
('NM', '35'),  -- New Mexico
('NY', '36'),  -- New York
('NC', '37'),  -- North Carolina
('ND', '38'),  -- North Dakota
('MP', '69'),  -- Northern Mariana Islands
('OH', '39'),  -- Ohio
('OK', '40'),  -- Oklahoma
('OR', '41'),  -- Oregon
('PA', '42'),  -- Pennsylvania
('PR', '72'),  -- Puerto Rico
('RI', '44'),  -- Rhode Island
('SC', '45'),  -- South Carolina
('SD', '46'),  -- South Dakota
('TN', '47'),  -- Tennessee
('TX', '48'),  -- Texas
('UT', '49'),  -- Utah
('VT', '50'),  -- Vermont
('VI', '78'),  -- Virgin Islands
('VA', '51'),  -- Virginia
('WA', '53'),  -- Washington
('WV', '54'),  -- West Virginia
('WI', '55'),  -- Wisconsin
('WY', '56');  -- Wyoming"

DBI::dbExecute(con, states)

utilities <- "alter table nbm_block
add column if not exists geoid_st char(2);
alter table nbm_block
add column if not exists geoid_co char(5);
update nbm_block
set geoid_st = substring(geoid_bl, 1, 2);
update nbm_block
set geoid_co = substring(geoid_bl, 1, 5);

alter table nbm_block
add column if not exists state_abbr char(2);
update nbm_block
set state_abbr = us_states.state_abbr
from us_states
where nbm_block.geoid_st = us_states.geoid_st;"

DBI::dbExecute(con, utilities)

message(sprintf("Starting to create parquet file: %s", Sys.time()))

write_parquet <- "copy (
  select 
	geoid_bl,
	geoid_st,
	geoid_co,
	state_abbr,
	cnt_total_locations,
	cnt_bead_locations,
	cnt_copper_locations,
	cnt_cable_locations,
	cnt_fiber_locations,
	cnt_other_locations,
	cnt_unlicensed_fixed_wireless_locations,
	cnt_licensed_fixed_wireless_locations,
	cnt_LBR_fixed_wireless_locations,
	cnt_terrestrial_locations,
	cnt_25_3,
	cnt_100_20,
	cnt_100_100,
	cnt_distcint_frn,
	array_frn,
	combo_frn,
	release
  from 
  	nbm_block
  order by geoid_bl) 
to 'nbm_block' (FORMAT PARQUET, PARTITION_BY(state_abbr), CODEC 'SNAPPY');"

DBI::dbExecute(con, write_parquet)

write_rel_combo <-
  "copy (
   from rel_combo_frn order by frn
    ) to 'rel_combo_frn.parquet' (format parquet, CODEC 'SNAPPY', ROW_GROUP_SIZE 100000)"

DBI::dbExecute(con, write_rel_combo)

DBI::dbDisconnect(con)

system("aws s3 sync nbm_block s3://cori.data.fcc/nbm_block")

system("aws s3 cp 'rel_combo_frn.parquet' s3://cori.data.fcc/rel_combo_frn.parquet")
