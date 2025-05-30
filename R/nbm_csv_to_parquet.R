#' Convert CSVs to parquet for NBM data
#'
#' Draft version of converting a lot of FCC NBM CSVs into a parquet file system
#' DuckDB is quite greedy on your system (but fast)
#'
#' @param parquet_name a path were the parquet files should be stored
#' @param src_directory a directory containing only the csv needed
#' @param part_one a string defining the first column to partition the parquet file
#' @param part_two a string defining the second column to partition the parquet file
#'
#' @return 0 if the execute went well and write a parquet file
#'
#' @import DBI
#' @import duckdb
#'
#' @examples
#' \dontrun{
#' system("unzip ~/data_swamp/\*.zip")
#' fcc_to_parquet("june23")
#' }
#### TODO: update this code with improved functionality from data-raw/nbm_raw.R... #' @export
nbm_csv_to_parquet <- function(parquet_name,
                           src_directory = "~/data_swamp/",
                           part_one = "state_abbr",
                           part_two = "technology") {
  # should be in tempfile/dir
  con <- DBI::dbConnect(duckdb::duckdb(),  dbdir = "temp.canard")
  on.exit(duckdb::dbDisconnect(con), add = TRUE)
  on.exit(if (file.exists("temp.canard")) {file.remove("temp.canard")},
          add = TRUE)
  on.exit(if (file.exists("temp.canard.wal")) {file.remove("temp.canard.wal")},
          add = TRUE)

  copy_stat <- sprintf("COPY
    (SELECT frn,
            provider_id,
            brand_name,
            location_id,
            technology,
            max_advertised_download_speed,
            max_advertised_upload_speed,
            business_residential_code,
            state_usps as state_abbr,
            block_geoid,
            low_latency
    FROM read_csv('%s/*.csv',
                  delim=',', quote='\"',
                  new_line='\\n', skip=0, header=true))
    TO '%s' (FORMAT 'parquet', PARTITION_BY(%s, %s))",
    src_directory, parquet_name, part_one, part_two)

  DBI::dbExecute(con, copy_stat)
}