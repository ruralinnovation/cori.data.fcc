#' Dictionary for our datasets
#'
#' Currently we are providing, Form 477 (f477) data and National Broadband Map
#' at the broadband services location (NBM_raw) level or
#' processed at Census Block (NBM_block)
#'
#' @format ## `fcc_dictionary`
#' A data frame with 15 rows and 5 columns:
#' \describe{
#'   \item{dataset}{name of the dataset}
#'   \item{var_name}{name of a field/columns}
#'   \item{var_type}{Data type}
#'   \item{var_description}{Description either provided by FCC or describing what was our process}
#'   \item{var_example}{One illustration}
#' }
#' @source <https://www.fcc.gov/general/explanation-broadband-deployment-data>
"fcc_dictionary"