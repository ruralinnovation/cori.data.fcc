# TODO: Download (cache) entire nbm_block dataset and make function to get opinionated county level summary

#' Load part of NBM counts for givent Census County from CORI S3 bucket
#'
#' Get all the data related to a county.
#'
#' A row in this data represent a Census County (2020 vintage).
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param geoid_co a string of 5-digit numbers
#' @param release a string with value "D23", "J24", "D24" (respectively targeting releases from December 2023, June 2024, December 2024)
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   nbm_bl <- get_nbm_county(geoid_co = "47051", release = "D24")
#' }
get_nbm_county <- function(geoid_co, release = "latest") {

  release_target <- ""

  if (release %in% c("D23", "J24", "D24")) {
    release_target <- paste0("-", release)
  }

  if (nchar(geoid_co) != 5L) stop("geoid_co should be a 5-digit string")

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  # DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  statement <- sprintf(
    paste0("select
            geoid_co as geoid,
            sum(cnt_total_locations) as cnt_total_locations,
            sum(cnt_fiber_locations) as cnt_fiber_locations,
            sum(cnt_100_20) as cnt_100_20,
            sum(cnt_25_3) as cnt_25_3
 		  from read_parquet('inst/ext_data/nbm/nbm_block", release_target, "/*/*.parquet')
    where geoid_co = '%s';"), geoid_co)

  ## TODO: If no geoid_co (county FIPS) specified, create summary for all counties...
  # statement <- c(
  #   "SELECT
  #           geoid_co as geoid,
  #           sum(cnt_total_locations) as cnt_total_locations,
  #           sum(cnt_fiber_locations) as cnt_fiber_locations,
  #           sum(cnt_100_20) as cnt_100_20,
  #           sum(cnt_25_3) as cnt_25_3
  #       FROM read_parquet('inst/ext_data/nbm/nbm_block", release_target, "/*/*.parquet')
  #   GROUP BY geoid;"
  # )

  DBI::dbGetQuery(con, statement)
}


