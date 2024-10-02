## code to prepare `dictionary` dataset goes here

### F477
# Source: https://www.fcc.gov/general/explanation-broadband-deployment-data
### NBM
# Source: https://us-fcc.app.box.com/v/bdc-data-downloads-output

geoid_bl_desc <- "15-digit U.S. Census Bureau FIPS code for the census block in which the Broadband Serviceable Location is located"
geoid_co_desc <- "5-digit U.S. Census Bureau for county, 2 first numbers represent a State and last 3 a county within a state"
geoid_st_desc <- "2-digit U.S. Census Bureau for states"
state_abbr_desc <- "2-character USPS abbreviation for the state/territory in which the Broadband Serviceable Location is located"
frn_desc <- "10-digit FCC Registration Number (FRN) of the entitythat submitted the data"
release <- "Availability data vintage in Month letter (J or D for June or December respectively) and 2digit year (i.e. J23) converted as Date"

f477 <- data.frame(
  dataset = "f477",
  var_name = c(
    "Provider_Id",
    "FRN",
    "ProviderName",
    "DBAName",
    "HoldingCompanyName",
    "HocoNum",
    "HocoFinal",
    "StateAbbr",
    "BlockCode",
    "TechCode",
    "Consumer",
    "MaxAdDown",
    "MaxAdUp",
    "Business",
    "Date"
  ),
  var_type = c(
    "TEXT",
    "TEXT",
    "VARCHAR",
    "VARCHAR",
    "VARCHAR",
    "TEXT",
    "TEXT",
    "CHAR(2)",
    "CHAR(15)",
    "VARCHAR(2)",
    "BOOLEAN",
    "SMALLINT",
    "SMALLINT",
    "BOOLEAN",
    "Date"
  ),
  var_description = c(
    "filing number (assigned by FCC)",
    "FCC registration number",
    "Provider name",
    "'Doing business as' name",
    "Holding company name (as filed on Form 477)",
    "Holding company number (assigned by FCC)",
    "Holding company name (attribution by FCC)",
    "2-letter state abbreviation used by the US Postal Service",
    "15-digit census block code used in the 2010 US Census",
    "2-digit code indicating the Technology of Transmission used to offer broadband service",
    "(0/1) where 1 = Provider can or does offer consumer/mass market/residential service in the block",
    "Maximum advertised downstream speed/bandwidth (in Mbps) offered by the provider in the block for Consumer service",
    "Maximum advertised upstream speed/bandwidth (in Mbps) offered by the provider in the block for Consumer service",
    "(0/1) where 1 = Provider can or does offer business/government service in the block",
    "Date of the release, provided in file name"),
  var_example = c(
    "8026",
    "0001570936",
    "Arctic Slope Telephone Association Cooperative, Inc.",
    "ASTAC",
    "Arctic Slope Telephone Association Cooperative, Inc.",
    "130067",
    "Arctic Slope Telephone Association Cooperative, Inc.",
    "AK",
    "021850001001047",
    11L,
    "true",
    1,
    0,
    "true",
    "2014-12-01 00:00:00"
  )
)

nbm_raw <- data.frame(
  dataset = "nbm_raw",
  var_name = c("frn",
               "provider_id",
               "brand_name ",
               "location_id",
               "technology",
               "max_advertised_download_speed",
               "max_advertised_upload_speed",
               "low_latency",
               "business_residential_code",
               "state_usps",
               "geoid_bl",
               "geoid_co",
               "file_time_stamp",
               "release"),
  var_type = c("CHAR(10)",
               "TEXT",
               "TEXT",
               "TEXT",
               "VARCHAR(2)",
               "INTEGER",
               "INTEGER",
               "BOOLEAN",
               "VARCHAR(1)",
               "VARCHAR(2)",
               "VARCHAR(15)",
               "VARCHAR(5)",
               "Date",
               "Date"),
  var_description = c(
    frn_desc,
    "Unique identifier for the fixed service provider",
    "Name of the entity or service advertised or offered to consumers",
    "Unique identifier for the location, as used in theBroadband Serviceable Location Fabric",
    "Code for the technology used for the deployed TODO service table link",
    "Maximum advertised download speed offered at the location in Mbps",
    "Maximum advertised upload speed associated withthe maximum advertised download speed offered atthe location in Mbps",
    "Boolean integer flag indicating whether or not the offered service is low latency, defined as having round-trip latency of less than or equal to 100 msbased on the 95th percentile of measurements 0/1, False/True",
    "Enumerated character identifying whether the serviceat the location is offered only to business customers (B) ,only to residential customers (R), or to both business and residential customers(X)",
    state_abbr_desc,
    geoid_bl_desc,
    geoid_co_desc,
    "FCC Revision Date, 23Jun202, convert to Date format",
    release),
  var_example = c("0032176356",
                  "999100",
                  "Acme Telecom",
                  "1357135307",
                  "50",
                  "1000",
                  "1000",
                  "1",
                  "B",
                  "DC",
                  "110010106033002",
                  "11001",
                  "2024-05-10",
                  "2022-06-01")
)

nbm_block <- data.frame(
  dataset = "nbm_block",
  var_name = c("geoid_bl", "geoid_st", "geoid_co", "state_abbr",
  "cnt_total_locations", "cnt_bead_locations", "cnt_copper_locations",
  "cnt_cable_locations", "cnt_fiber_locations", "cnt_other_locations",
  "cnt_unlicensed_fixed_wireless_locations",
  "cnt_licensed_fixed_wireless_locations",
  "cnt_LBR_fixed_wireless_locations", "cnt_terrestrial_locations",
  "cnt_25_3", "cnt_100_20", "cnt_100_100", "cnt_distcint_frn",
  "array_frn", "combo_frn", "release"
  ),
  var_type = c("VARCHAR(15)", "VARCHAR(2)", "VARCHAR(5)",
               "VARCHAR(2)", "INTEGER", "INTEGER", "INTEGER",
               "INTEGER", "INTEGER", "INTEGER", "INTEGER",
               "INTEGER", "INTEGER", "INTEGER", "INTEGER",
               "INTEGER", "INTEGER", "INTEGER",
               "VARCHAR[]", "UBIGINT", "DATE"),
  var_description = c(geoid_bl_desc, geoid_st_desc, geoid_co_desc,
                      state_abbr_desc,
                      "Count of the total number of locations",
                      "Count of the locations that are NOT only covered by a satellite or by an unlicensed wireless services and must provide download and upload speed above 0 MBps",
                      "Count of locations covered by copper technology",
                      "Count of locations covered by cable technology",
                      "Count of locations covered by fiber technology",
                      "Count of locations covered by Other technology",
                      "Count of locations covered by unlicensed fixed wireless technology",
                      "Count of locations covered by licensed fixed wireless technology",
                      "Count of locations covered by licensed-by-Rule (LBR) fixed wireless technology",
                      "Count of locations covered by terrestrial technology",
                      "Count of locations covered by greater or equal 25/3 Maximum advertised download/upload speed",
                      "Count of locations covered by greater or equal 100/20 Maximum advertised download/upload speed",
                      "Count of locations covered by greater or equal 100/100 Maximum advertised download/upload speed",
                      "Count the number of ISP represented by their FRN excluding ISP only providing satellite services",
                      "List of FRN excluding ISP only providing satellite services",
                      "Hash, using DuckDB hash function of the list of FRN",
                      release),
  var_example = c("020130001003033","02", "02013", "AK", "40", "39", "0", "0", "39",
                  "0", "0", "0", "0", "39", "39", "39", "0", "1",
                  "[0004991444, 0018506568]",
                  14501455127825750734, "2023-12-01")
)

fcc_dictionary <- rbind(f477, nbm_raw, nbm_block)

usethis::use_data(fcc_dictionary, overwrite = TRUE)
