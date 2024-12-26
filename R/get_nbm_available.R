#' Get a list of files availables in FCC servers
#'
#' NBM's API:
#' ```
#' paste0("https://broadbandmap.fcc.gov/nbm/",
#'        "map/api/national_map_process/nbm_get_data_download/")
#' ```
#' @param get_root_url a string providing NBM filing API.
#' 
#' @return A data frame.
#' @export
#'
#' @examples
#' nbm_data <- get_nbm_available()
#' head(nbm_data)

get_nbm_available <- function(
  get_root_url = paste0("https://broadbandmap.fcc.gov/nbm/map/",
                        "api/national_map_process/nbm_get_data_download/")
) {

  # get csv to dl only get a table with all link to be downloaded
  get_csv_to_dl <- function(release_file, release_nb) {
    get_data_url <- paste0(get_root_url,
                           release_file[release_nb, "process_uuid"])

    dest_file <- paste0(tempdir(), "/", release_file[release_nb, "process_uuid"], ".json")

    res <- download_file(get_data_url, dest_file)

    # Check res
    if (!(dest_file %in% res)) {
      message(paste0("Error in download result: ", res))
      stop(sprintf("Downloading %s failed", get_data_url))
    }

    csv_to_dl <- jsonlite::fromJSON(res)[["data"]]

    csv_to_dl[["release"]] <- release_file[release_nb, "filing_subtype"]
    return(csv_to_dl)
  }

  release <- get_nbm_release()

  release

  big_list <- lapply(seq_len(nrow(release)), get_csv_to_dl, release_file = release)

  all_data <- do.call(rbind, big_list)

  col_to_keep <- c("id", "release", "data_type", "technology_code",
                   "state_fips", "provider_id", "file_name", "file_type",
                   "data_category")

  slim_all_data <- all_data[, col_to_keep]
  return(slim_all_data)
}
