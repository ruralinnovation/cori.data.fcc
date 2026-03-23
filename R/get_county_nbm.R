# TODO: Download (cache) entire nbm_block dataset and make function to get opinionated county level summary

#' Load part of NBM at Census Block from CORI S3 bucket
#'
#' Get all the data related to a states or county.
#'
#' A row in this data represent a census block (2020 vintage).
#' Use `get_fcc_dictionary("nbm_block")` to get a description of the date.
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param geoid_co a string of 5-digit numbers
#' @param release a string with value "D23", "J24", "D24", "J25" (respectively targeting releases from December2023, June2024, December2024, June2025)
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#' @examples
#' \dontrun{
#'   nbm_bl <- get_nbm_bl(geoid_co = "47051")
#' }

get_nbm_bl <- function(geoid_co, release = "latest") {

  release_target <- ""

  if (release %in% c("D23", "J24", "D24", "J25")) {
    release_target <- paste0("-", release)
  } else {
    release_target <- "-J25"
  }

  if (nchar(geoid_co) != 5L) stop("geoid_co should be a 5-digit string")

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  DBI::dbExecute(con, "SET s3_region = 'us-east-1';")
  DBI::dbExecute(con, "SET s3_url_style = 'path';")
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  statement <- sprintf(
    paste0("select *
 		  from read_parquet('inst/ext_data/nbm/nbm_block", release_target, "/*/*.parquet')
    where geoid_co = '%s';"), geoid_co)

  statement <- c(
    "SELECT
            geoid_co as geoid,
            sum(cnt_total_locations) as cnt_total_locations,
            sum(cnt_fiber_locations) as cnt_fiber_locations,
            sum(cnt_100_20) as cnt_100_20,
            sum(cnt_25_3) as cnt_25_3
        FROM read_parquet('inst/ext_data/nbm/nbm_block", release_target, "/*/*.parquet')
    GROUP BY geoid;"
  )

  DBI::dbGetQuery(con, statement)
}


