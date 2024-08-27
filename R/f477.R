
describe_f477 <- function(year, us_states) {

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

  statement <- sprintf("select state_abbr, geoid_bl, census_vintage, year, value
                       from  
                      read_parquet(
                      's3://fcc-data-cori/fcc_staff/*/*/*.parquet')
                      where year = %s and state_abbr = '%s' ;", year, us_states)

  DBI::dbGetQuery(con, statement)

}