#' Get release available in FCC NBM 
#'
#' @param filing_url a string providing NBM filing API. Default is "https://broadbandmap.fcc.gov/nbm/map/api/published/filing" 
#' @param useragent set a default user agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0"
#' 
#' @return A data frame.
#' @export
#'
#' @examples
#' nbm <- get_nbm_release()

get_nbm_release <- function(filing_url = "https://broadbandmap.fcc.gov/nbm/map/api/published/filing",
                            useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0") {
  h <- curl::new_handle()
  curl::handle_setheaders(h,
                          "User-Agent" = useragent)
  req <- curl::curl_fetch_memory(filing_url, handle = h)
  release <- jsonlite::fromJSON(rawToChar(req$content))$data
  return(release)
}


get_nbm_available <- function(get_data_url ="https://broadbandmap.fcc.gov/nbm/map/api/national_map_process/nbm_get_data_download/") {

  get_csv_to_dl <- function(release_file, release_nb) {
    get_data_url <- paste0(get_data_url,
                                release_file[release_nb, "process_uuid"])

    raw_dat <- curl::curl_fetch_memory(get_data_url)

    csv_to_dl <- jsonlite::fromJSON(rawToChar(raw_dat$content))$data
    csv_to_dl[["release"]] <- release_file[release_nb, "filing_subtype"] 
    return(csv_to_dl)
  }

  release <- get_nbm_release()

  big_list <- lapply(1:nrow(release), get_csv_to_dl, release_file = release)

  all_data <- do.call(rbind, big_list)

  col_to_keep <- c("release", "data_type", "technology_code",
                   "state_fips", "provider_id", "file_name", "file_type",
                  "data_category")

  slim_all_data <- all_data[, col_to_keep]
}