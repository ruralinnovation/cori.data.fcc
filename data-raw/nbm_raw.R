## code to prepare `NBM` dataset goes here

library(cori.data.fcc)
library(duckdb)

data_dir <- "inst/ext_data/nbm"

source_dir <- paste0(data_dir, "/source")

release <- get_nbm_release()

nbm_data <- get_nbm_available()

system(sprintf("mkdir -p %s", source_dir))

# # this is a big loop
# for (i in release$filing_subtype){
#   dl_nbm(
#     path_to_dl = source_dir,
#     release_date = i,
#     data_type = "Fixed Broadband",
#     data_category = "Nationwide")
# }

source("data-raw/nbm_downloads.R")

num_files <- nbm_data |>
  dplyr::filter(data_type == "Fixed Broadband" &
                  data_category == "Nationwide") |>
  nrow()
# checking if we have all the files
num_files_dl <- length(list.files(source_dir, pattern = "*.zip"))

stopifnot("we are missing some files" = identical(num_files, num_files_dl))


raw_dta_dir <- paste0(data_dir, "/raw")

system(sprintf("mkdir -p %s", raw_dta_dir))

system(sprintf("unzip %s/\\*.zip -d %s", source_dir, raw_dta_dir))

system(sprintf("du -sh %s", raw_dta_dir))
# ~~290G    inst/ext_data/nbm/raw~~
# 585G	inst/ext_data/nbm/raw


## Fix some files names (from "...December20ec..." to "...December20dec...")

# Get all CSV files in the source directory
csv_files <- list.files(raw_dta_dir, pattern = "\\.csv$", full.names = TRUE)

# Find December20... files that contain the incorrect pattern
bad_file_names <- csv_files[grepl("December20ec_", basename(csv_files))]

files_renamed <- list()

# Rename the files
for (file in bad_file_names) {
  # Get the directory and current filename
  dir_path <- dirname(file)
  old_name <- basename(file)
  
  # Create the new filename by replacing the incorrect pattern
  new_name <- gsub("December20ec_", "December20_", old_name)
  
  # Construct full paths
  old_path <- file
  new_path <- file.path(dir_path, new_name)
  
  # Rename the file
  file.rename(old_path, new_path)

  files_renamed[[length(files_renamed) + 1]] <- new_name
  
  # Print confirmation (optional)
  cat("Renamed:", old_name, "->", new_name, "\n")
}

# Check how many files were renamed
cat("Total files renamed:", length(files_renamed), "\n")


# Find "June20..." files that contain the incorrect pattern
bad_file_names <- csv_files[grepl("June20un_", basename(csv_files))]

files_renamed <- list()

# Rename the files
for (file in bad_file_names) {
  # Get the directory and current filename
  dir_path <- dirname(file)
  old_name <- basename(file)
  
  # Create the new filename by replacing the incorrect pattern
  new_name <- gsub("June20un_", "June20_", old_name)
  
  # Construct full paths
  old_path <- file
  new_path <- file.path(dir_path, new_name)
  
  # Rename the file
  file.rename(old_path, new_path)

  files_renamed[[length(files_renamed) + 1]] <- new_name
  
  # Print confirmation (optional)
  cat("Renamed:", old_name, "->", new_name, "\n")
}

# Check how many files were renamed
cat("Total files renamed:", length(files_renamed), "\n")


## files name follow some nice pattern but J23 or D22 are hard to convert in sql to a Date
# better do that in R

raw_csv <- list.files(raw_dta_dir, pattern = "*.csv", recursive = FALSE)
raw_csv <- paste0(raw_dta_dir, "/", raw_csv)

files_renamed <- list()

better_fcc_name <- function(file_name) {
  print(file_name)
  # First check if full release month is already in the file name
  if (grepl("December", file_name) || grepl("June", file_name)) {
    return(file_name)
    
  } else {

    convert_date <- function(string) {
        m <- substring(string, 1, 1)
        y <- substring(string, 2, 3)
        if (m == "D") month <- "December" else month <- "June"
        year <- paste0("20", y)
        return(paste0(month, year))
    }

    dir_name <- dirname(file_name)
    bad_file_name <- basename(file_name)
    split_bad_file_name <- unlist(strsplit(bad_file_name, split = "_"))
    split_bad_file_name[6] <- convert_date(split_bad_file_name[6])
    good_file_name <- paste(split_bad_file_name, collapse = "_")
    good_file_path <- paste(dir_name, good_file_name, sep = "/")

    print(paste0(bad_file_name, " changed to ", good_file_name))

    return(good_file_path)
  }
}

better_name <- vapply(raw_csv, better_fcc_name, FUN.VALUE = character(1))

rename_results <- file.rename(raw_csv, better_name)

# Check how many files were renamed
cat("Total files renamed:", sum(rename_results), "\n")


duck_dir <- paste0(data_dir, "/duckdb")
dir.create(duck_dir, recursive = TRUE, showWarnings = FALSE)

con <- DBI::dbConnect(duckdb::duckdb(), dbdir = paste0(duck_dir, "/nbm.duckdb"))

## I went overkill with that one, it is probably not needed
DBI::dbExecute(con, "PRAGMA max_temp_directory_size='10GiB'")

copy_stat <- paste0("
COPY
    (SELECT 
      frn, 
      provider_id, 
      brand_name,
      location_id,
      technology,
      max_advertised_download_speed,
      max_advertised_upload_speed,
      low_latency,
      business_residential_code,
      state_usps,
      block_geoid as geoid_bl, 
      substring(block_geoid, 1, 5) as geoid_co,
      strptime(split_part(split_part(filename, '_', 8), '.', 1), '%d%b%Y')::DATE
       as file_time_stamp,
      strptime(split_part(filename, '_', 7), '%B%Y')::DATE as release 
    FROM 
    read_csv(
             '", raw_dta_dir, "/*.csv',
              types = { 
                        'frn'        : 'VARCHAR(10)',
                        'provider_id': 'TEXT',
                        'brand_name' : 'TEXT',
                        'location_id': 'TEXT', 
                        'technology' : 'VARCHAR(2)', 
                        'max_advertised_download_speed' : INTEGER,
                        'max_advertised_upload_speed' : INTEGER,
                        'low_latency' : 'BOOLEAN',
                        'business_residential_code': 'VARCHAR(1)',
                        'state_usps' : 'VARCHAR(2)',
                        'block_geoid': 'VARCHAR(15)'  
    },   
              ignore_errors = true,         
              delim=',', quote='\"',
              new_line='\\n', skip=0, 
              header=true, filename=true))
    TO '", data_dir, "/nbm_raw' (FORMAT 'parquet', PARTITION_BY(release, state_usps, technology), OVERWRITE true);"
)

DBI::dbExecute(con, copy_stat)

DBI::dbDisconnect(con)

# system("aws s3 sync nbm_raw s3://cori.data.fcc/nbm_raw")

# ## update January 2025, adding June2024
# # assuming list of csv in data_swamp

# library(duckdb)

# con <- DBI::dbConnect(duckdb::duckdb(),  tempfile())

# # I needed to run because FCC naming J24 can be june, january ... 
# data_dir <- "data_swamp/10dec2024/"

# raw_csv <- list.files(data_dir, pattern = "*.csv", recursive = TRUE)
# raw_csv <- paste0(data_dir, raw_csv)

# # better names is defined above
# better_name <- vapply(raw_csv, better_fcc_name, FUN.VALUE = character(1))

# file.rename(raw_csv, better_name)


# ## I went overkill with that one, it is probably not needed
# DBI::dbExecute(con, "PRAGMA max_temp_directory_size='10GiB'")

# copy_stat <- "
# COPY
#     (SELECT 
#       frn, 
#       provider_id, 
#       brand_name,
#       location_id,
#       technology,
#       max_advertised_download_speed,
#       max_advertised_upload_speed,
#       low_latency,
#       business_residential_code,
#       state_usps,
#       block_geoid as geoid_bl, 
#       substring(block_geoid, 1, 5) as geoid_co,
#       strptime(split_part(split_part(filename, '_', 8), '.', 1), '%d%b%Y')::DATE
#        as file_time_stamp,
#       strptime(split_part(filename, '_', 7), '%B%Y')::DATE as release 
#     FROM 
#     read_csv(
#              'data_swamp/10dec2024/*.csv',
#               types = { 
#                         'frn'        : 'VARCHAR(10)',
#                         'provider_id': 'TEXT',
#                         'brand_name' : 'TEXT',
#                         'location_id': 'TEXT', 
#                         'technology' : 'VARCHAR(2)', 
#                         'max_advertised_download_speed' : INTEGER,
#                         'max_advertised_upload_speed' : INTEGER,
#                         'low_latency' : 'BOOLEAN',
#                         'business_residential_code': 'VARCHAR(1)',
#                         'state_usps' : 'VARCHAR(2)',
#                         'block_geoid': 'VARCHAR(15)'  
#     },   
#               ignore_errors = true,         
#               delim=',', quote='\"',
#               new_line='\\n', skip=0, 
#               header=true, filename=true))
#     TO 'nbm_raw' (FORMAT 'parquet', PARTITION_BY(release, state_usps, technology)
#     );"

# DBI::dbExecute(con, copy_stat)

# DBI::dbDisconnect(con)

# system("aws s3 sync nbm_raw/release=2024-12-01 s3://cori.data.fcc/nbm_raw/release=2024-12-01")
