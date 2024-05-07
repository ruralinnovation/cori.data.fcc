#' Get info on 1 frn
#'
#' @param frn
#'
#' @return a table with info on FRN
#' @export
#'
#' @examples
#' check_frn(8181448)

check_frn <- function(frn) {
    frn_pad <- sprintf("%010s", frn)
    fcc_provider[fcc_provider[["FRN"]] == frn_pad,]
}