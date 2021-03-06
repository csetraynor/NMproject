% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NMproject.R
\name{nm_default_dirs}
\alias{nm_default_dirs}
\title{setup analysis subdirectories}
\usage{
nm_default_dirs(dir_list)
}
\arguments{
\item{dir_list}{optional named list or vector. Names "scripts_dir" and "models_dir" must be present.  Rest can be unnamed}
}
\value{
if `dir_list` is missing, will return value of `getOption("nm_default_dirs")` otherwise will set option `nm_default_dirs`
}
\description{
This allows organisations/individuals with their own directory to customize their directory structure
}
\examples{
\dontrun{

nm_default_dirs()
nm_default_dirs(list(models = "Models", 
                     scripts = "Scripts",
                     results = "Results",
                     "SourceData",
                     "Data"))
}
}
