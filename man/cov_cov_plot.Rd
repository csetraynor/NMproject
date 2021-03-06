% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/covariate_building.R
\name{cov_cov_plot}
\alias{cov_cov_plot}
\title{Plot correlation between two covariates}
\usage{
cov_cov_plot(
  d,
  cov,
  continuous,
  log_transform_plot = rep(FALSE, length(cov)),
  dcov_info,
  by = "ID"
)
}
\arguments{
\item{d}{dataset with covariates}

\item{cov}{vector of length 2 for covariate names}

\item{continuous}{logical vector of length 2 for whether cov is continuous or not}

\item{log_transform_plot}{should plot be log transformed or not}

\item{dcov_info}{option dataframe with covariate information}

\item{by}{character (default = "ID") variable to split over}
}
\description{
Plot correlation between two covariates
}
