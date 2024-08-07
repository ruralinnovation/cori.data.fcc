the <- new.env(parent = emptyenv())
the$user_agent <- paste0("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
                         " AppleWebKit/537.36 (KHTML, like Gecko)",
                         " Chrome/112.0.0.0 Safari/537.36")

#' Seting user agent for function
#' @export
user_agent <- function() {
  the$user_agent
}

#' Change User-Agent for a specific session
#'
#' Functions in this package use a specific User-Agent.
#' You can change it for a specific R session.
#'
#' @param user_agent a string representing an User-Agent
#'
#' @export
#'
#'@examples
#'\dontrun{
#' set_user_agent(
#' paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
#' " (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
#'}

set_user_agent <- function(user_agent) {
  stopifnot(is.character(user_agent))
  old <- the$user_agent
  the$user_agent <- user_agent
  invisible(old)
}