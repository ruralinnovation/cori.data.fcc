#' Display FCC variables and associated descriptions
#'
#' Return dictionary for a all datasets. Available dataset are "f477", "nbm_raw" and "nbm_block".
#'
#' @param dataset a string matching a dataset, default is "all"
#'
#' @return a data frame
#'
#' @export
#'
#' @examples
#' get_fcc_dictionary("nbm_block")

get_fcc_dictionary <- function(dataset = "all") {
  dict <- cori.data.fcc::fcc_dictionary
  if (dataset == "all") {
    return(dict)
  } else {
    filter <- dict[dict[["dataset"]] == dataset, ]
    return(filter)
  }
}