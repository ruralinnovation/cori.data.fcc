## code to prepare `f477` dataset goes here
library(DBI)
library(cori.db)
library(data.table)
library(dplyr)
library(duckdb)
library(tictoc)


data_dir <- "inst/ext_data" # <= Must have underscore to work with duckdb query used later
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

s3_bucket_name <- "cori.data.fcc"
source_prefix <- "source"
dir.create(paste0(data_dir, "/", source_prefix), recursive = TRUE, showWarnings = FALSE)

source_files_s3 <- (
  cori.db::list_s3_objects(bucket_name = s3_bucket_name) |>
      dplyr::filter(grepl(source_prefix, `key`)) |>
      # dplyr::filter(grepl('Jun2021', `key`)) |> # <= test filter
      dplyr::filter(grepl(".zip", `key`))
)$key

### Create clean and states directories (if they don't exist)
clean_dir <- paste0(data_dir, "/clean")
dir.create(clean_dir, recursive = TRUE, showWarnings = FALSE)
clean_states_dir <- paste0(clean_dir, "/states")
dir.create(clean_states_dir, recursive = TRUE, showWarnings = FALSE)


source_files_s3 |> lapply(function(x) {

  # MAIN LOOP

  print(paste0("Downloading ", x, " from s3://", s3_bucket_name))

  file_name <- basename(x)
  file_path <- paste0(data_dir, "/", source_prefix, "/", file_name)

  system(paste0("touch ", file_path))

  cori.db::get_s3_object(s3_bucket_name, x, file_path) # <= `x` includes source_prefix (i.e. "source")

  print(paste0("Finished downloading ", file_path))

  release_name <- gsub(".zip", "", basename(file_path))
  release_dir <- paste0(data_dir, "/", release_name)

  dir.create(release_dir, recursive = TRUE, showWarnings = FALSE)
  print(paste0("Unzip release contents to ", release_dir))

  unzip_command <- sprintf("unzip -u %s -d %s", file_path, release_dir)
  print(unzip_command)

  system(unzip_command)

  file_name <- list.files(release_dir, pattern = ".csv", recursive = FALSE)[1]
  file_path <- paste0(release_dir, "/", file_name)

  print(file_path)

  stopifnot(file.exists(file_path))

  tic()

  # Olivier says: weird encoding to fix
  # If missing uchardet command, install on Mac with: brew install uchardet
  uchardet_command <- paste0("uchardet ", file_path)
  encoding <- system(uchardet_command, intern = TRUE)

  print(list(file_name, encoding))

  # fbd_us_with_satellite_jun2021_v1.csv WINDOWS-1250

  # Requires iconv: https://linux.die.net/man/1/iconv
  s <- sprintf('iconv -f %s -t UTF8 %s > %s/%s',
              encoding, file_path, clean_dir, file_name)
  print(s)
  result <- system(s)

  stopifnot(length(result) > 0 && result[[1]] == 0)

  # Delete release dir (pre-cleaned US data set)
  unlink(release_dir, recursive = TRUE)

  file_path <- paste0(clean_dir, "/", file_name)

  stopifnot(file.exists(file_path))

  print(paste0("Finished writing UTF8 version of ", file_path))
  toc()

  # Before importing to duckdb, we need to fix quote errors
  # Ex.
  # "Camp Fox, LLC dba ""Island Fiber"""
  # ... shouldb be converted to "Camp Fox, LLC dba , Island Fiber, "

  tic()

  ### Read in entire release dataset
  # dt <- data.table::fread(file_path)
  dt <- data.table::fread(file = file_path,
              header = TRUE,
              sep = "\n",
              colClasses = c(FRN = "character",
                             MaxAdDown = "numeric",
                             MaxAdUp = "numeric"),
              stringsAsFactors = FALSE)

  print(head(dt))

  # states <- c("AL")
  states <- unique(dt$StateAbbr)

  ### partition on state
  states |> lapply(function(st_abbr){

    ### Subset and clean dt
    dt_st <- dt[StateAbbr == st_abbr,,]

    ## Write csv state tables by release to a "clean" subdirectory (states)
    file_name <- gsub("_us_", paste0("_", tolower(st_abbr), "_"), file_name)
    file_path <- paste0(clean_states_dir, "/", file_name)

    system(paste0("touch ", file_path))

    result <- data.table::fwrite(dt_st, file_path)

    stopifnot(file.exists(file_path))

    rm(dt_st) # Remove subset data.table from the environment...

    ## ... then read it back in with readLines (works)
    old_lines <- readLines(file_path)

    # Process each line to handle multiple adjacent double-quoted strings
    process_line <- function(line) {
      # First, identify patterns matching a double quote followed by text and then double-double quotes
      # Keep applying the transformation until there are no more matches
      while(grepl('"[^"]*""[^"]*"', line)) {
        cat(paste0("Found: ", line))
        print("")
        # Replace patterns of the form "text1""text2" with "text1, text2,"
        line <- gsub('"([^"]*?)""([^"]*?)"', '"\\1, \\2"', line)
        cat(paste0("Changed: ", line))
        print("")
      }
      return(line)
    }

    # Apply the function to each line
    new_lines <- lapply(old_lines, process_line)

    # Delete original file
    unlink(file_path)

    # Write results to same file name
    writeLines(unlist(new_lines), file_path)

    print(paste0("Finished cleaning ", file_path))

    return(invisible(result))
  })

  # Delete clean US dataset
  unlink(file_path)

  print(paste0("Finished cleaning and writing all states for ", file_name))
  toc()

  return(invisible(result))

})


load_into_duckdb <- function (s3_bucket_name, pq_prefix, csv_dir) {

  pq_dir <- paste0(data_dir, "/", pq_prefix)

  # Olivier says: Magic of duckDB
  # FCC is not always very strict in following their data type
  # lot of time spend testing and adjusting to it
  # more can be found here:
  # https://www.fcc.gov/general/explanation-broadband-deployment-data
  # https://www.fcc.gov/general/technology-codes-used-fixed-broadband-deployment-dat# require uchardet

  duck_dir <- paste0(data_dir, "/duckdb")
  dir.create(duck_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = paste0(duck_dir, "/f477.duckdb"), op)
  on.exit(DBI::dbDisconnect(con))

  duckdb::dbSendQuery(con, "INSTALL httpfs;")
  duckdb::dbSendQuery(con, "LOAD httpfs;")
  duckdb::dbSendQuery(con, "INSTALL aws;")
  duckdb::dbSendQuery(con, "LOAD aws;")
  duckdb::dbSendQuery(con, "CREATE OR REPLACE SECRET s3_secret (
    TYPE S3,
    PROVIDER CREDENTIAL_CHAIN,
    CHAIN 'env;config'
);")

  ## I went overkill with that one, it is probably not needed
  DBI::dbExecute(con, "PRAGMA max_temp_directory_size='10GiB'")

  # DuckDb will round (up) SMALLINT values, so use decimal instead
  copy_stat <- paste0("
  COPY
    (SELECT
      Provider_Id,
      lpad(FRN, 10, '0') as FRN,
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
      strptime(split_part(filename, '_', 6), '%b%Y')::DATE as Date
      FROM read_csv(
        '", csv_dir, "/*.csv',
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
                    'MaxAdDown': 'DECIMAL(8, 3)',
                    'MaxAdUp': 'DECIMAL(8, 3)',
                    'Business': 'BOOLEAN'},
          delim=',', quote='\"',
          new_line='\\n', skip=0,
          header=true, filename=true
      )
    ) ",
# "    TO '", pq_dir, "' (FORMAT 'parquet', PARTITION_BY(Date, StateAbbr), OVERWRITE true);"
"    TO 's3://", s3_bucket_name, "/", pq_prefix, "' (FORMAT 'parquet', PARTITION_BY(Date, StateAbbr));" # <= Write parquet directly to S3, but FIRST you must manually delete prior data on S3
  )

  cat(copy_stat)

  result <- DBI::dbExecute(con, copy_stat)

  # result <- cori.db::put_s3_objects_recursive(s3_bucket_name, parquet_prefix, pq_dir) # <= This would overwrite S3 without first deleting... could be an issue for parquet

  return(invisible(result))
}

parquet_prefix <- "f477_with_satellite"

load_into_duckdb(s3_bucket_name, parquet_prefix, clean_states_dir)
