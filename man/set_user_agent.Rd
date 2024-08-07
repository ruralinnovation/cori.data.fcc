% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aaa.R
\name{set_user_agent}
\alias{set_user_agent}
\title{Change User-Agent for a specific session}
\usage{
set_user_agent(user_agent)
}
\arguments{
\item{user_agent}{a string representing an User-Agent}
}
\description{
Functions in this package use a specific User-Agent.
You can change it for a specific R session.
}
\examples{
\dontrun{
set_user_agent(
paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
" (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
}
}
