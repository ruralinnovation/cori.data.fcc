#' Load part of f477 estimates data from s3 bucket
#'
#' Source data: FCC Form 477
#'
#' @param us_states a directory containing only the csv needed
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#' @import duckdb
#'
#' @examples
#' \dontrun{
#' NC <- get_f477(us_states = "NC")
#' }

get_f477 <- function(us_states) {

  con <- DBI::dbConnect(duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")

  # would it be needed on public ?
  keyID <- Sys.getenv("AWS_ACCESS_KEY_ID")
  region <- Sys.getenv("AWS_DEFAULT_REGION")
  acces_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
  statement_keyID <- sprintf("SET s3_access_key_id='%s'", keyID)
  statement_region <- sprintf("SET s3_region='%s'", region)
  statement_acces_key <- sprintf("SET s3_secret_access_key='%s'", acces_key)

  DBI::dbExecute(con, statement_keyID)
  DBI::dbExecute(con, statement_region)
  DBI::dbExecute(con, statement_acces_key)

  statement <- sprintf("select *
                       from  
                      read_parquet(
                      's3://fcc-data-cori/f477/*/*/*.parquet')
                      where StateAbbr = '%s';", us_states)

  DBI::dbGetQuery(con, statement)

}