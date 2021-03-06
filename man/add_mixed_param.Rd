% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_object.R
\name{add_mixed_param}
\alias{add_mixed_param}
\title{add a mixed effect parameter to $PK (or $PRED)}
\usage{
add_mixed_param(
  m,
  name,
  init = 1,
  unit = "",
  trans = c("LOG"),
  position = NA_integer_,
  after = character()
)
}
\arguments{
\item{m}{nm object}

\item{name}{character. name of NONMEM variable to create}

\item{init}{numeric. initial value of fixed effect}

\item{unit}{character. unit of variable}

\item{trans}{character. tranformation to log scale?}

\item{position}{integer. not used}

\item{after}{character. patter to match and include the mixed effect after}
}
\description{
This will (by default) add a parameter (mixed effect) to your code
}
