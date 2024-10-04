## code to prepare `f477` dataset goes here

# the process to get f477 is a bit long
library(curl)
options(timeout = 600)

# first year are easy to access
list_url <- c(
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec14/Version%203/US-Fixed-without-Satellite-Dec2014.zip",
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun15/Version%205/US-Fixed-without-Satellite-Jun2015.zip",
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec15/Version%204/US-Fixed-without-Satellite-Dec2015.zip",
      "https://transition.fcc.gov/form477/BroadbandData/Fixed/Jun16/Version%204/US-Fixed-without-Satellite-Jun2016.zip",
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec16/Version%202/US-Fixed-without-satellite-Dec2016.zip",
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun17/Version%203/US-Fixed-without-Satellite-Jun2017.zip",
      "http://www.fcc.gov/form477/BroadbandData/Fixed/Dec17/Version%203/US-Fixed-without-satellite-Dec2017.zip",
      "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun18/Version%201/US-Fixed-without-Satellite-Jun2018.zip",
      "http://www.fcc.gov/form477/BroadbandData/Fixed/Dec18/Version%203/US-Fixed-without-Satellite-Dec2018.zip"

)

dir_swamp <- "data_swamp"
dir.create(dir_swamp)

list_url[1]

for (i in list_url) {
  curl::curl_download(i, paste0(dir_swamp, "/",
                                basename(i)))
}

# then FCC started to use box and I do not want an account here:
# and need to be downloaded manually

list_box <- c(
  "https://www.fcc.gov/form-477-broadband-deployment-data-june-2019-version-2",
  "https://www.fcc.gov/form-477-broadband-deployment-data-december-2019-version-1",
  "https://www.fcc.gov/form-477-broadband-deployment-data-june-2020-version-2",
  "https://www.fcc.gov/form-477-broadband-deployment-data-december-2020",
  "https://www.fcc.gov/form-477-broadband-deployment-data-june-2021",
  "https://us-fcc.box.com/v/US-without-Sat-Dec2021-v1"
)

system(sprintf("unzip data_swamp/\\*.zip -d %s", dir_swamp))

# should be 15 files

list.files("data_swamp/", pattern = "*.csv")
#  [1] "fbd_us_without_satellite_dec2014_v3.csv"
#  [2] "fbd_us_without_satellite_dec2015_v4.csv"
#  [3] "fbd_us_without_satellite_dec2016_v2.csv"
#  [4] "fbd_us_without_satellite_dec2017_v3.csv"
#  [5] "fbd_us_without_satellite_dec2018_v3.csv"
#  [6] "fbd_us_without_satellite_dec2019_v1.csv"
#  [7] "fbd_us_without_satellite_dec2020_v1.csv"
#  [8] "fbd_us_without_satellite_dec2021_v1.csv"
#  [9] "fbd_us_without_satellite_jun2015_v5.csv"
# [10] "fbd_us_without_satellite_jun2016_v4.csv"
# [11] "fbd_us_without_satellite_jun2017_v3.csv"
# [12] "fbd_us_without_satellite_jun2018_v1.csv"
# [13] "fbd_us_without_satellite_jun2019_v2.csv"
# [14] "fbd_us_without_satellite_jun2020_v2.csv"
# [15] "fbd_us_without_satellite_jun2021_v1.csv"

# weird encoding to fix

encoding <- system("uchardet data_swamp/*.csv", intern = TRUE)

# data_swamp/fbd_us_without_satellite_dec2014_v3.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2015_v4.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2016_v2.csv: UTF-8
# data_swamp/fbd_us_without_satellite_dec2017_v3.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2018_v3.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2019_v1.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2020_v1.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_dec2021_v1.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2015_v5.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2016_v4.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2017_v3.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2018_v1.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2019_v2.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2020_v2.csv: ISO-8859-2
# data_swamp/fbd_us_without_satellite_jun2021_v1.csv: WINDOWS-1250


system("mkdir -p data_swamp/clean/")

# require iconv: https://linux.die.net/man/1/iconv

convert_to_utf8 <- function(x) {
  l_f <- unlist(strsplit(x, ":"))
  s <- sprintf("iconv -f %s -t UTF8 %s > data_swamp/clean/%s",
               l_f[2], l_f[1], basename(l_f[1]))
  print(s)
  system(s)
}

for (i in encoding) {
  convert_to_utf8(i)
}

# Magic of duckDB
# FCC is not always very strict in following their data type
# lot of time spend testing and adjusting to it
# more can be found here:
# https://www.fcc.gov/general/explanation-broadband-deployment-data
# https://www.fcc.gov/general/technology-codes-used-fixed-broadband-deployment-dat# require uchardet

library(duckdb)

con <- DBI::dbConnect(duckdb::duckdb(),  tempfile())

## I went overkill with that one, it is probably not needed
DBI::dbExecute(con, "PRAGMA max_temp_directory_size='10GiB'")

copy_stat <- "
COPY
    (SELECT 
      Provider_Id, 
      FRN, 
      ProviderName,
      DBAName,
      HoldingCompanyName,
      HocoNum,
      HocoFinal,
      StateAbbr,
      BlockCode,
      TechCode,
      Consumer,
      MaxAdDown,
      MaxAdUp,
      Business,
      strptime(split_part(filename, '_', 6), '%b%Y') as Date
    FROM 
    read_csv(
             'data_swamp/clean/*.csv',
              types = { 'LogRecNo': 'BIGINT',
                        'Provider_Id' : 'TEXT',
                        'FRN' : 'TEXT',
                        'ProviderName': 'VARCHAR',
                        'DBAName' : 'VARCHAR',
                        'HoldingCompanyName' : 'VARCHAR',
                        'HocoNum' : 'TEXT',
                        'HocoFinal': 'TEXT',
                        'StateAbbr': 'CHAR(2)',
                        'BlockCode': 'CHAR(15)',
                        'TechCode': 'VARCHAR(2)',
                        'Consumer': 'BOOLEAN',
                        'MaxAdDown': 'SMALLINT',
                        'MaxAdUp': 'SMALLINT',
                        'Business': 'BOOLEAN'},            
              delim=',', quote='\"',
              new_line='\\n', skip=0, 
              header=true, filename=true))
    TO 'f477' (FORMAT 'parquet', PARTITION_BY(Date, StateAbbr)
    );"

DBI::dbExecute(con, copy_stat)

DBI::dbDisconnect(con)