## code to prepare `dictionary` dataset goes here

### F477
# source https://www.fcc.gov/general/explanation-broadband-deployment-data

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
    "Date of the release, provided in file name"
  ),
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


usethis::use_data(dictionary, overwrite = TRUE)