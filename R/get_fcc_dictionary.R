#' Display FCC variables and associated descriptions
#'
#' Return dictionary for a all datasets. Available dataset are "f477" (`get_f477`), "nbm_raw" (`get_nbm_county_raw`) and "nbm_block" (`get_nbm_bl`, `get_nbm_county`).
#'
#' @param dataset a string matching a dataset, default is "all"
#'
#' @return a data frame
#'
#' @export
#'
#' @examples
#' get_fcc_dictionary("nbm_block")

get_fcc_dictionary <- function(dataset = c("all", "f477", "nbm_raw", "nbm_block")) {
  dataset <- match.arg(dataset)

  dict <- cori.data.fcc::fcc_dictionary
  if (dataset == "all") {
    return(dict)
  } else {
    filter <- dict[dict[["dataset"]] == dataset, ]
    return(filter)
  }
}
