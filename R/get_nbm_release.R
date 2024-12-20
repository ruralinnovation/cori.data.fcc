#' Get a list of release available in FCC NBM
#'
#' @param filing_url a string providing NBM filing API. Default is "https://broadbandmap.fcc.gov/nbm/map/api/published/filing"
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' nbm <- get_nbm_release()

get_nbm_release <- function(filing_url = "https://broadbandmap.fcc.gov/nbm/map/api/published/filing") {

  dest_file <- paste0(tempdir(), "/filing.json")

  res <- download_file(filing_url, dest_file)

  # Check res
  if (!(dest_file %in% res)) {
    message(paste0("Error in download result: ", res))
    stop(sprintf("Downloading %s failed", filing_url))
  }
  release <- jsonlite::fromJSON(res)[["data"]]

  return(release)
}