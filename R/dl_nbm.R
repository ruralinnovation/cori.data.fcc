#' Download NBM data
#'
#' Function that download all NBM data related to CORI works. 
#' It takes a path to download the zipped csv.
#'
#' @param path_to_dl a string by default "~/data_swamp"
#' @param release_date a string can be "December 31, 2023" or "June 30, 2023"
#' @param data_type a string "Fixed Broadband"
#' @param data_category a string "Nationwide"
#' @param ... additional parameters for download.file()
#'
#' @return Zipped csv
#' @export
#'
#' @examples
#' \dontrun{
#' system("mkdir -p  ~/data_swamp")
#' dl_nbm(release_date = "June 30, 2023")
#' }


dl_nbm <- function(path_to_dl = "~/data_swamp",
                   release_date = "June 30, 2023",
                   data_type = "Fixed Broadband",
                   data_category = "Nationwide", ...) {
  # clean my mess
  prev_timeout <- getOption("timeout")
  on.exit(options(timeout = prev_timeout), add = TRUE)
  options(timeout = max(360, getOption("timeout")))


  base_url <- "https://broadbandmap.fcc.gov/nbm/map/api/getNBMDataDownloadFile/"

  all_data_to_dl <- get_nbm_available()
  one_release_to_dl <- all_data_to_dl[all_data_to_dl$release == release_date, ]
  one_release_to_dl <-
    one_release_to_dl[one_release_to_dl$data_type == data_type, ]
  one_release_to_dl <-
    one_release_to_dl[one_release_to_dl$data_category == data_category, ]

  # def should be refactored ..
  for (i in seq_len(nrow(one_release_to_dl))) {

    dest_file <- paste0(path_to_dl, "/",
                        one_release_to_dl$file_name[i],
                        ".zip")

    if (file.exists(dest_file)) {
      print(paste(dest_file, "already downloaded, skipping it"))
      next
    }

    get_data_url <- paste0(base_url, one_release_to_dl$id[i], "/1")

    res <- download_file(get_data_url, dest_file)

    # Check res
    if (!(dest_file %in% res)) {
      message(paste0("Error in download result: ", res))
      stop(sprintf("Downloading %s failed", get_data_url))
    }

  }
}