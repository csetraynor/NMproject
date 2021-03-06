% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_project.R
\name{ls_code_library}
\alias{ls_code_library}
\title{List files in code library}
\usage{
ls_code_library(pattern = ".")
}
\arguments{
\item{pattern}{optional character. filter the code library use regex}
}
\description{
List files in code library
}
\examples{

\dontrun{

ls_code_library("Models/ADVAN2.mod") \%>\%
  stage()
  
}

}
\seealso{
\code{\link{code_library}}, \code{\link{preview}}, \code{\link{stage}}, \code{\link{import}}
}
