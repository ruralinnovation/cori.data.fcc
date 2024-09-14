#' Display FCC variable and descriptions
#'
#' @param dataset a string matching a dataset
#'
#' @return a data frame
#'
#' @export
#'
#' @examples

get_fcc_dictionary <- function(dataset) {
  dict <- cori.data.fcc::fcc_dictionary
  dict[dict[["dataset"]] == dataset, ]
}