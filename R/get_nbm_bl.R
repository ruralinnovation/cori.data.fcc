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
#' @param release a string with value "D23", "J24", "D24" (respectively targeting releases from December2023, June2024, December24)
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

  if (release %in% c("D23", "J24", "D24")) {
    release_target <- paste0("-", release)
  }

  if (nchar(geoid_co) != 5L) stop("geoid_co should be a 5-digit string")

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  statement <- sprintf(
    paste0("select *
 		  from read_parquet('s3://cori.data.fcc/nbm_block", release_target, "/*/*.parquet')
    where geoid_co = '%s';"), geoid_co)

  DBI::dbGetQuery(con, statement)
}