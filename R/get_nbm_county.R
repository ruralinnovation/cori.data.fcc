#' Load NBM service counts for given Census County from CORI S3 bucket
#'
#' Get all the data related to a county.
#'
#' A row in this data represent a Census County (2020 vintage).
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param geoid_co a string of 5-digit numbers
#' @param release a string with value "D23", "J24", "D24" (respectively targeting releases from December 2023, June 2024, December 2024)
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   nbm_bl <- get_nbm_county(geoid_co = "47051", release = "D24")
#' }
get_nbm_county <- function(geoid_co, release = "latest") {

  ## Download nbm_release parquet
  data_dir <- paste0(here::here(), "/inst/ext_data/nbm")
  if (! dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

  release_target <- ""

  if (release %in% c("D23", "J24", "D24")) {
    release_target <- paste0("-", release)
  }
  s3_bucket_name <- "cori.data.fcc"

  nbm_release <- paste0("nbm_block", release_target)
  nbm_release_dir <- paste0(data_dir, "/", nbm_release)

  if (! dir.exists(nbm_release_dir)) {
    dir.create(nbm_release_dir, recursive = TRUE, showWarnings = FALSE)

    s3_data_files <- (
      cori.db::list_s3_objects(bucket_name = s3_bucket_name) |>
        dplyr::filter(grepl(nbm_release, `key`))
    )$`key`

    if (!all(s3_data_files %in% list.files(data_dir, recursive = TRUE, full.names = FALSE))) {
      s3_download_command <- paste0("aws s3 cp --recursive s3://", s3_bucket_name, "/", nbm_release, " ", nbm_release_dir)

      print(s3_download_command)

      system(s3_download_command)
    }
  }

  if (nchar(geoid_co) != 5L) stop("geoid_co should be a 5-digit string")

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  # DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  statement <- sprintf(
    paste0("select
            geoid_co as geoid,
            sum(cnt_total_locations) as cnt_total_locations,
            sum(cnt_fiber_locations) as cnt_fiber_locations,
            sum(cnt_100_20) as cnt_100_20,
            sum(cnt_25_3) as cnt_25_3
 		  from read_parquet('", nbm_release_dir, "/*/*.parquet')
    where geoid_co = '%s'
    group by geoid
    ;"), geoid_co)

  ## TODO: If no geoid_co (county FIPS) specified, create summary for all counties...
  # statement <- c(
  #   "SELECT
  #           geoid_co as geoid,
  #           sum(cnt_total_locations) as cnt_total_locations,
  #           sum(cnt_fiber_locations) as cnt_fiber_locations,
  #           sum(cnt_100_20) as cnt_100_20,
  #           sum(cnt_25_3) as cnt_25_3
  #       FROM read_parquet('", nbm_release_dir, "/*/*.parquet')
  #   GROUP BY geoid;"
  # )

  DBI::dbGetQuery(con, statement)
}


