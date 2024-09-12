#' Display FCC variable and descriptions
#'
#' @param dataset a string matching a dataset
#'
#' @return a data frame
#'
#' @export
#'
#' @examples

fcc_dictionary <- function(dataset) {
  dict <- cori.data.fcc::dictionary
  dict[dict[["dataset"]] == dataset, ]
}