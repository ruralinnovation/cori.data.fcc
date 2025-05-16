## code to prepare `f477` dataset goes here
library(DBI)
library(cori.db)
library(dplyr)
library(duckdb)
library(tictoc)


data_dir <- "inst/ext_data" # <= must have underscore to work with duckdb query used later
dir.create(data_dir, recursive = TRUE)

## TODO: REDO all of this WITH Satellite data

# # the process to get f477 is a bit long
# library(curl)
# options(timeout = 600)


# # first year are easy to access
# list_url <- c(
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec14/Version%203/US-Fixed-with-Satellite-Dec2014.zip",
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun15/Version%205/US-Fixed-with-Satellite-Jun2015.zip",
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec15/Version%204/US-Fixed-with-Satellite-Dec2015.zip",
#       "https://transition.fcc.gov/form477/BroadbandData/Fixed/Jun16/Version%204/US-Fixed-with-Satellite-Jun2016.zip",
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Dec16/Version%202/US-Fixed-with-satellite-Dec2016.zip",
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun17/Version%203/US-Fixed-with-Satellite-Jun2017.zip",
#       "http://www.fcc.gov/form477/BroadbandData/Fixed/Dec17/Version%203/US-Fixed-with-satellite-Dec2017.zip",
#       "https://www.fcc.gov/form477/BroadbandData/Fixed/Jun18/Version%201/US-Fixed-with-Satellite-Jun2018.zip",
#       "http://www.fcc.gov/form477/BroadbandData/Fixed/Dec18/Version%203/US-Fixed-with-Satellite-Dec2018.zip"

# )

# list_url[1]

# for (i in list_url) {
#   curl::curl_download(i, paste0(data_dir, "/",
#                                 basename(i)))
# }

# # then FCC started to use box and I do not want an account here:
# # and need to be downloaded manually


# list_box <- c(
#   "https://www.fcc.gov/form-477-broadband-deployment-data-june-2019-version-2",
#   "https://www.fcc.gov/form-477-broadband-deployment-data-december-2019-version-1",
#   "https://www.fcc.gov/form-477-broadband-deployment-data-june-2020-version-2",
#   "https://www.fcc.gov/form-477-broadband-deployment-data-december-2020",
#   "https://www.fcc.gov/form-477-broadband-deployment-data-june-2021",
#   "https://us-fcc.box.com/v/US-with-Sat-Dec2021-v1"
# )

s3_bucket_name <- "cori.data.fcc"
source_prefix <- "source"
dir.create(paste0(data_dir, "/", source_prefix), recursive = TRUE)

source_files_s3 <- (
  cori.db::list_s3_objects(bucket_name = s3_bucket_name) |> 
      dplyr::filter(grepl(source_prefix, `key`)) |> 
      dplyr::filter(grepl(".zip", `key`))
)$key

tic()
source_files_s3 |> lapply(function(x) {

  cori.db::get_s3_object(s3_bucket_name, x, paste0(data_dir, "/", x))

  print(paste0("Fininshed downloading ", data_dir, "/", x))
})
toc()

unzip_command <- sprintf("unzip -u %s/\\*.zip -d %s", paste0(data_dir, "/", source_prefix), data_dir)
print(unzip_command)

system(unzip_command)

# should be 15 files
list.files(data_dir, pattern = "*.csv")

### TODO: Originally downloaded these files...
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

### ... but we're switching to *with_satellite (full data set)
# [1] "fbd_us_with_satellite_dec2014_v3.csv"
# [2] "fbd_us_with_satellite_dec2015_v4.csv"
# [3] "fbd_us_with_satellite_dec2016_v2.csv"
# [4] "fbd_us_with_satellite_dec2017_v3.csv"
# [5] "fbd_us_with_satellite_dec2018_v3.csv"
# [6] "fbd_us_with_satellite_dec2019_v1.csv"
# [7] "fbd_us_with_satellite_dec2020_v1.csv"
# [8] "fbd_us_with_satellite_dec2021_v1.csv"
# [9] "fbd_us_with_satellite_jun2015_v5.csv"
# [10] "fbd_us_with_satellite_jun2016_v4.csv"
# [11] "fbd_us_with_satellite_jun2017_v3.csv"
# [12] "fbd_us_with_satellite_jun2018_v1.csv"
# [13] "fbd_us_with_satellite_jun2019_v2.csv"
# [14] "fbd_us_with_satellite_jun2020_v2.csv"

# system("mkdir -p data_swamp/clean/")
clean_dir <- paste0(data_dir, "/clean")
dir.create(clean_dir, recursive = TRUE)

csv_files <- list.files(data_dir, pattern = ".csv", recursive = FALSE)

convert_to_utf8_and_clean <- function(file_path) {

  tic()

  # weird encoding to fix
  # If missing uchardet command, install on Mac with: brew install uchardet
  file_name <- basename(file_path)
  uchardet_command <- paste0("uchardet ", data_dir, "/", file_name)
  encoding <- system(uchardet_command, intern = TRUE)

  print(list(file_name, encoding))

  # fbd_us_with_satellite_jun2021_v1.csv WINDOWS-1250

  # Requires iconv: https://linux.die.net/man/1/iconv
  s <- sprintf('iconv -f %s -t UTF8 %s/%s > %s/clean/%s',
               encoding, data_dir, file_name, data_dir, file_name)
  print(s)
  result <- system(s)

  stopifnot(length(result) > 0 && result[[1]] == 0)

  unlink(paste0(data_dir, "/", file_name))
  
  print(paste0("Fininshed writing UTF8 version of ", file_name))
  toc()

  # Before importing to duckdb, we need to fix quote errors
  # Ex.
  # "Camp Fox, LLC dba ""Island Fiber"""
  # ... shouldb be converted to "Camp Fox, LLC dba , Island Fiber, "

  tic()

  # Read the file
  old_lines <- readLines(paste0(data_dir, "/clean/", file_name))

  # Process each line to handle multiple adjacent double-quoted strings
  process_line <- function(line) {
    # First, identify patterns matching a double quote followed by text and then double-double quotes
    # Keep applying the transformation until there are no more matches
    while(grepl('"[^"]*""[^"]*"', line)) {
      # cat(paste0("Found: ", line))
      # print("")
      # # Replace patterns of the form "text1""text2" with "text1, text2,"
      line <- gsub('"([^"]*?)""([^"]*?)"', '"\\1, \\2"', line)
      # cat(paste0("Changed: ", line))
      # print("")
    }
    return(line)
  }

  # Apply the function to each line
  new_lines <- lapply(old_lines, process_line)

  # Delete original file
  unlink(paste0(data_dir, "/clean/", file_name))

  # Write results to same file name
  writeLines(unlist(new_lines), paste0(data_dir, "/clean/", file_name))
  
  print(paste0("Fininshed cleaning ", file_name))
  toc()
  
  return(invisible(result))
}

csv_files |> lapply(convert_to_utf8_and_clean)

load_into_duckdb <- function (pq_prefix) {
  # Magic of duckDB
  # FCC is not always very strict in following their data type
  # lot of time spend testing and adjusting to it
  # more can be found here:
  # https://www.fcc.gov/general/explanation-broadband-deployment-data
  # https://www.fcc.gov/general/technology-codes-used-fixed-broadband-deployment-dat# require uchardet

  duck_dir <- paste0(data_dir, "/duckdb")
  dir.create(duck_dir, recursive = TRUE)

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = paste0(duck_dir, "/f477.duckdb"), op)
  on.exit(DBI::dbDisconnect(con))

  ## I went overkill with that one, it is probably not needed
  DBI::dbExecute(con, "PRAGMA max_temp_directory_size='10GiB'")

  # DuckDb will round (up) SMALLINT values, so use decimal instead
  copy_stat <- paste0("
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
            '", clean_dir, "/*.csv',
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
    TO '", data_dir, "/", pq_prefix, "' (FORMAT 'parquet', PARTITION_BY(Date, StateAbbr), OVERWRITE true);
  "
  )

  cat(copy_stat)

  result <- DBI::dbExecute(con, copy_stat)

  return(invisible(result))
}

parquet_prefix <- "f477_with_satellite"

load_into_duckdb(parquet_prefix)

cori.db::put_s3_objects_recursive(s3_bucket_name, parquet_prefix, paste0(data_dir, "/", parquet_prefix))
