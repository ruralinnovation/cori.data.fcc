#' Load part of the NBM data
#'
#' Get all the data related to NBM related to a county.  
#' A row in this data represent a service per census block (2020 vintage).
#' By default the function will return all the ISP but a specific FRN
#' (10 number strings, ie "0007435902") can also be used to be more specific.
#'
#' Source data: FCC Broadband Funding Map
#'
#' @param geoid_co a string matching a GEOID for a county
#' @param frn a string of 10 numbers matching FCC's FRN, default is "all"
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#' @import duckdb
#'
#'@examples
#'\dontrun{
#'NC <- get_nbm_raw(geoid_co = "37081")
#'}

get_nbm_raw <- function(geoid_co, frn = "all") {

  # do I need a look up for county 

  con <- DBI::dbConnect(duckdb())
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
                        where geoid_co = '%s' and release = '2023-12-01';", geoid_co)

  } else {

    statement <- sprintf("select *
                         from
                         read_parquet(
                         's3://cori.data.fcc/nbm_raw/*/*/*/*.parquet')
                         where  geoid_co = '%s' and frn = '%s'and release = '2023-12-01';",
                         geoid_co, frn)
  }

  DBI::dbGetQuery(con, statement)

}
