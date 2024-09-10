#' Load part of f477 estimates data from s3 bucket
#'
#' Source data: FCC Form 477
#'
#' @param state_abbr a string matching state abbr
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

get_f477 <- function(state_abbr) {

  con <- DBI::dbConnect(duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")

  statement <- sprintf("select *
                       from  
                      read_parquet(
                      's3://cori.data.fcc/f477/*/*/*.parquet')
                      where StateAbbr = '%s';", state_abbr)

  DBI::dbGetQuery(con, statement)

}
