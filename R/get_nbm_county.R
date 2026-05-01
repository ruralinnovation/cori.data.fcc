#' Load NBM Broadband Servicable Location (BSL) counts for given Census County from CORI S3 bucket
#'
#' Get all the data related to a county.
#'
#' A row in this data represent a Census County (2020 vintage).
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param geoid_co a string of 5-digit numbers
#' @param release a string with value "D23", "J24", "D24", "J25" (respectively targeting releases from December2023, June2024, December2024, June2025)
#' @param data_dir path to download directory
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#' @examples
#' \dontrun{
#'   nbm_bl <- get_nbm_county(geoid_co = "47051")
#' }
get_nbm_county <- function(geoid_co, release = c("latest", "D23", "J24", "D24", "J25"), data_dir = tempdir()) {

  release <- match.arg(release)

  if (release %in% c("D23", "J24", "D24", "J25")) {
    release_target <- paste0("-", release)
  } else {
    release_target <- "-J25"
  }

  if (nchar(geoid_co) != 5L) stop("geoid_co should be a 5-digit string")

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

  state_abbr <- fips_to_state[[substr(geoid_co, 1, 2)]]

  # print(data_dir)

  local_state_dir <- file.path(
    data_dir,
    paste0("nbm_block", release_target),
    paste0("state_abbr=", state_abbr)
  )

  if (!dir.exists(local_state_dir)) {

    dir.create(local_state_dir, recursive = TRUE, showWarnings = FALSE)

    s3_src <- sprintf(
      "s3://cori.data.fcc/nbm_block%s/state_abbr=%s/",
      release_target, state_abbr
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

  statement <- sprintf(
    "SELECT
          geoid_co as geoid,
          sum(cnt_total_locations) as cnt_total_locations,
          sum(cnt_fiber_locations) as cnt_fiber_locations,
          sum(cnt_100_20) as cnt_100_20,
          sum(cnt_25_3) as cnt_25_3
        FROM
        read_parquet(
          '%s/*.parquet')
        WHERE geoid = '%s'
        GROUP BY geoid;",
    local_state_dir, geoid_co)

  # # TODO: Download (cache) entire nbm_block dataset
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
