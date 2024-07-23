#' Get info on one or nor FRN
#'
#' @param frn one or more FCC FRN, it can be a number or a string
#'
#' @return a table with info on FRN
#' @export
#'
#' @importFrom stringi stri_pad_left
#' 
#' @examples
#' check_frn(8181448)

check_frn <- function(frn) {
  frn_pad <- stringi::stri_pad_left(frn, width = 10, pad = "0")
  filter <- cori.data.fcc::fcc_provider[["frn"]] %in% frn_pad
  dat <- cori.data.fcc::fcc_provider[filter, ]
  return(dat)
}
