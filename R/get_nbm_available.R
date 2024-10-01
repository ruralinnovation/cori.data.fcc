#' Get release available in FCC NBM
#'
#' NBM's API: 
#' ```
#' paste0("https://broadbandmap.fcc.gov/nbm/",
#'        "map/api/national_map_process/nbm_get_data_download/")
#' ```
#' @param get_data_url a string providing NBM filing API.
#' @param user_agent a string set up by default
#' 
#' @return A data frame.
#' @export
#'
#' @examples
#' nbm_data <- get_nbm_available()

get_nbm_available <- function(
  get_data_url = paste0("https://broadbandmap.fcc.gov/nbm/map/",
                        "api/national_map_process/nbm_get_data_download/"),
  user_agent = the$user_agent) {

  get_csv_to_dl <- function(release_file, release_nb) {
    get_data_url <- paste0(get_data_url,
                           release_file[release_nb, "process_uuid"])
    # h <- curl::new_handle()
    # curl::handle_setheaders(h, "User-Agent" = user_agent)
    #
    # raw_dat <- curl::curl_fetch_memory(get_data_url)
    #
    # csv_to_dl <- jsonlite::fromJSON(rawToChar(raw_dat$content))$data

    res <- system(
      sprintf("curl '%s' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' -H 'Sec-GPC: 1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers'",
              get_data_url),
      intern = TRUE)
    csv_to_dl <- jsonlite::fromJSON(res)[["data"]]

    csv_to_dl[["release"]] <- release_file[release_nb, "filing_subtype"]
    return(csv_to_dl)
  }

  release <- cori.data.fcc::get_nbm_release()

  big_list <- lapply(seq_len(nrow(release)), get_csv_to_dl, release_file = release)

  all_data <- do.call(rbind, big_list)

  col_to_keep <- c("id", "release", "data_type", "technology_code",
                   "state_fips", "provider_id", "file_name", "file_type",
                   "data_category")

  slim_all_data <- all_data[, col_to_keep]
  return(slim_all_data)
}