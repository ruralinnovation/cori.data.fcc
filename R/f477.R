#' Load part of f477 estimates data from s3 bucket
#'
#' Get all the census block 
#' Source data: FCC Form 477
#'
#' @param state_abbr a string matching state abbr
#' @param frn a string of 10 numbers matching FCC's FRN, default is "all" 
#' 
#' @return a data frame
#'
#' @export
#' @import DBI
#' @import duckdb
#'
#' @examples
#' \dontrun{
#' NC <- get_f477(state_abbr = "NC")
#' }

get_f477 <- function(state_abbr, frn = "all") {

  state_abbr <- state_abbr_lookup(state_abbr)

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
                        's3://cori.data.fcc/f477/*/*/*.parquet')
                        where StateAbbr = '%s';", state_abbr)

  } else {
 
    statement <- sprintf("select *
                         from
                         read_parquet(
                         's3://cori.data.fcc/f477/*/*/*.parquet')
                         where StateAbbr = '%s' and frn = '%s';",
                         state_abbr, frn)
  }

  DBI::dbGetQuery(con, statement)

}
