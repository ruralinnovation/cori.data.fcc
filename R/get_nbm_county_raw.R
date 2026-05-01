#' Load all BSL from NBM dataset for a specific county
#'
#' Attention: Depending on the county it can take some times.
#'
#' Get all the BSL from NBM dataset for a specific county specified by it's geoid.
#' A row in this data represent a service per location_id.
#' By default the function will return all the ISP but a specific FRN and the last release.
#' (10 number strings, ie "0007435902") can also be used to be more specific.
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param geoid_co a string matching a GEOID for a county
#' @param frn a string of 10 numbers matching FCC's FRN, default is "all"
#' @param release a date, set by default to be '2025-06-01'
#' @param data_dir path to download directory
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#'@examples
#'\dontrun{
#'  guilford_cty <- get_nbm_county_raw(geoid_co = "37081")
#'}
get_nbm_county_raw <- function(geoid_co, frn = "all", release = "2025-06-01", data_dir = tempdir()) {

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  DBI::dbExecute(con, "SET s3_region = 'us-east-1';")
  DBI::dbExecute(con, "SET s3_url_style = 'path';")
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  fips_to_state <- c(
    "01" = "AL", "02" = "AK", "04" = "AZ", "05" = "AR", "06" = "CA",
    "08" = "CO", "09" = "CT", "10" = "DE", "11" = "DC", "12" = "FL",
    "13" = "GA", "15" = "HI", "16" = "ID", "17" = "IL", "18" = "IN",
    "19" = "IA", "20" = "KS", "21" = "KY", "22" = "LA", "23" = "ME",
    "24" = "MD", "25" = "MA", "26" = "MI", "27" = "MN", "28" = "MS",
    "29" = "MO", "30" = "MT", "31" = "NE", "32" = "NV", "33" = "NH",
    "34" = "NJ", "35" = "NM", "36" = "NY", "37" = "NC", "38" = "ND",
    "39" = "OH", "40" = "OK", "41" = "OR", "42" = "PA", "44" = "RI",
    "45" = "SC", "46" = "SD", "47" = "TN", "48" = "TX", "49" = "UT",
    "50" = "VT", "51" = "VA", "53" = "WA", "54" = "WV", "55" = "WI",
    "56" = "WY", "60" = "AS", "66" = "GU", "69" = "MP", "72" = "PR",
    "78" = "VI"
  )

  state_usps <- fips_to_state[[substr(geoid_co, 1, 2)]]

  # print(data_dir)

  local_state_dir <- file.path(
    data_dir,
    paste0("release=", release),
    paste0("state_usps=", state_usps)
  )

  if (!dir.exists(local_state_dir)) {
    
    dir.create(local_state_dir, recursive = TRUE, showWarnings = FALSE)
    
    s3_src <- sprintf(
      "s3://cori.data.fcc/nbm_raw/release=%s/state_usps=%s/",
      release, state_usps
    )
    s3_sync_results <- system2(
      "aws",
      args = c("s3", "sync", s3_src, local_state_dir),
      stdout = TRUE, stderr = TRUE
    )
    if (!is.null(attr(s3_sync_results, "status")) && attr(s3_sync_results, "status") != 0) {
      stop("aws s3 sync failed: ", paste(s3_sync_results, collapse = "\n"))
    }
  }

  if (frn == "all") {

    statement <- sprintf("select *
                         from
                           read_parquet(
                             '%s/*/*.parquet')
                         where geoid_co = '%s' and release = '%s';",
                         local_state_dir, geoid_co, release)

  } else {

    statement <- sprintf("select *
                         from
                           read_parquet(
                             '%/*/*.parquet')
                          where  geoid_co = '%s' and frn = '%s' and release = '%s';",
                         local_state_dir, geoid_co, frn, release)
  }

  DBI::dbGetQuery(con, statement)

}
