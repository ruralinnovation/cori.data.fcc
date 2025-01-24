#' Load part of NBM at Census Block from CORI s3 bucket
#'
#' Get all the data related to a FRN.
#' A row in this data represent a census block (2020 vintage).
#'
#' IMPORTANT: We are not counting blocks:
#' * when covered only by satellite servives
#' * and discarding a location when a service of 0/0 download/uploads speeds.
#'
#' Use `get_fcc_dictionary("nbm_block")` to get a description of the date.
#' A FRN is a 10 number strings, ie "0007435902" can also be used to be more specific.
#'
#' Data Source: FCC Broadband Data Collection
#'
#' @param frn a string of 10 numbers matching FCC's FRN
#'
#' @return a data frame
#'
#' @export
#' @import DBI
#'
#'@examples
#'\dontrun{
#'  skymesh <- get_frn_nbm_bl("0027136753")
#'}

get_frn_nbm_bl <- function(frn) {

  if (nchar(frn) != 10L) stop("frn should be a 10-digit string")

  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con,
                 sprintf("SET temp_directory ='%s';", tempdir()))
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs;LOAD httpfs")
  statement <- sprintf(
   "select * 
 		  from read_parquet('s3://cori.data.fcc/nbm_block-J24/*/*.parquet')
    where 
      combo_frn in (
    							  select combo_frn 
    							  from 
										read_parquet('s3://cori.data.fcc/rel_combo_frn-J24.parquet')
    								where frn = '%s'
    );", frn)

  DBI::dbGetQuery(con, statement)
}