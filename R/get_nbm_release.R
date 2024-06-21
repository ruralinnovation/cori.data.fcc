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
