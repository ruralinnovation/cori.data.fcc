#' Download NBM data
#'
#' Function that download all NBM data related to CORI works. 
#' It takes a path to download the zipped csv.
#'
#' @param path_to_dl a string by default "~/data_swamp"
#' @param release_date a string can be "December 31, 2023" or "June 30, 2023"
#' @param data_type a string "Fixed Broadband"
#' @param data_category a string "Nationwide"
#' @param user_agent a string set up by default
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
                   data_category = "Nationwide",
                   user_agent = the$user_agent, ...) {
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
    res <- system(
      sprintf(
        paste0("curl '%s' --compressed ",
               "-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0' ",
               "-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' ",
               "-H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' ",
               "-H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' ",
               "-H 'Referer: https://broadbandmap.fcc.gov/data-download' ",
               "-H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' ",
               "-H 'Sec-GPC: 1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' ",
               "-o %s"),
        get_data_url, dest_file
        )
      )
    # unsure if an error in a system call return 0 consistantly but oh well
    if (res != 0) {
      stop(sprintf("Downloading %s failed", get_data_url))
    }
  }
}