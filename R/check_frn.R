#' Get info on one or nor FRN
#'
#' @param frn one or more FCC FRN, it can be a number or a string
#'
#' @return a table with info on FRN
#' @export
#'
#' @examples
#' check_frn(8181448)

check_frn <- function(frn) {
  frn_pad <- sprintf("%010s", frn)
  filter <- cori.data.fcc::fcc_provider[["frn"]] %in% frn_pad
  dat <- cori.data.fcc::fcc_provider[filter, ]
  return(dat)
}
