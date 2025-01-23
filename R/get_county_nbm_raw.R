#' Load all BSL from NBM dataset for a specific county
#'
#'
#' Attention: Depending on the county it can take some times.
#'
#' Get all the BSL from NBM dataset for a specific county specified by it's geoid.
#' A row in this data represent a service per location_id.
#' By default the function will return all the ISP but a specific FRN and the last release.
#' (10 number strings, ie "0007435902") can also be used to be more specific.
#'
#' Source data: FCC Broadband Funding Map
#'
#' @param geoid_co a string matching a GEOID for a county
#' @param frn a string of 10 numbers matching FCC's FRN, default is "all"
#' @param release a date, set by default to be '2024-06-01'
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#'@examples
#'\dontrun{
#'  guilford_cty <- get_county_nbm_raw(geoid_co = "37081")
#'}

get_county_nbm_raw <- function(geoid_co, frn = "all", release = "2024-06-01") {

  # do I need a look up for county?

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")

  # slippery slopes
  if (frn == "all") {

    statement <- sprintf("select *
                         from
                           read_parquet(
                             's3://cori.data.fcc/nbm_raw/*/*/*/*.parquet')
                         where geoid_co = '%s' and release = '%s';",
                         geoid_co, release)

  } else {

    statement <- sprintf("select *
                         from
                           read_parquet(
                             's3://cori.data.fcc/nbm_raw/*/*/*/*.parquet')
                          where  geoid_co = '%s' and frn = '%s' and release = '%s';",
                         geoid_co, frn, release)
  }

  DBI::dbGetQuery(con, statement)

}
