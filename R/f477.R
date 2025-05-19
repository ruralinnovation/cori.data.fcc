#' Load part of Form 477 estimates data from CORI s3 bucket
#'
#' Get all the data related to Form 477 for a US State.
#' A row in this data represent a service per census block (2010 vintage).
#' By default the function will return all the ISP but a specific FRN
#' (10 number strings, ie "0007435902") can also be used to be more specific.
#'
#' Source data: FCC Form 477
#'
#' @param state_abbr a string matching State Abbreviation ("NC", "vt")
#' @param frn a string of 10 numbers matching FCC's FRN, default is "all"
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#'@examples
#'\dontrun{
#'  NC <- get_f477(state_abbr = "NC")
#'}

get_f477 <- function(state_abbr, frn = "all") {

  state_abbr <- state_abbr_lookup(state_abbr)

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
                        's3://cori.data.fcc/f477_with_satellite/*/*/*.parquet')
                        where StateAbbr = '%s';", state_abbr)

  } else {

    statement <- sprintf("select *
                         from
                         read_parquet(
                         's3://cori.data.fcc/f477_with_satellite/*/*/*.parquet')
                         where StateAbbr = '%s' and frn = '%s';",
                         state_abbr, frn)
  }

  DBI::dbGetQuery(con, statement)

}
