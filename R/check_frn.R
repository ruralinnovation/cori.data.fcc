#' Get info on one frn
#'
#' @param frn a FCC FRN, it can be a number or a string
#'
#' @return a table with info on FRN
#' @export
#'
#' @examples
#' check_frn(81814488181448)

check_frn <- function(frn) {
  frn_pad <- sprintf("%010s", frn)
  fcc_provider[fcc_provider[["FRN"]] == frn_pad, ]
}