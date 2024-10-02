#' Get release available in FCC NBM
#'
#' @param filing_url a string providing NBM filing API. Default is "https://broadbandmap.fcc.gov/nbm/map/api/published/filing"
#' @param user_agent set a default user agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0"
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' nbm <- get_nbm_release()

get_nbm_release <- function(filing_url = "https://broadbandmap.fcc.gov/nbm/map/api/published/filing",
                            user_agent = the$user_agent) {
  # h <- curl::new_handle()
  # curl::handle_setheaders(h,
  #                         "User-Agent" = user_agent)
  # req <- curl::curl_fetch_memory(filing_url, handle = h)
  # release <- jsonlite::fromJSON(rawToChar(req$content))$data

  res <- system(
    sprintf("curl '%s' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' -H 'Sec-GPC: 1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers'",
            filing_url),
    intern = TRUE)
  release <- jsonlite::fromJSON(res)[["data"]]

  return(release)
}