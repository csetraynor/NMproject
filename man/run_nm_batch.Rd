% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_nm.R
\name{run_nm_batch}
\alias{run_nm_batch}
\title{run_nm in batches}
\usage{
run_nm_batch(m, threads = 10, ...)
}
\arguments{
\item{m}{nm object}

\item{threads}{numeric.  Number of threads to un}

\item{...}{additional arguments passed to run_nm()}
}
\description{
a variant of \code{run_nm()} that will submit run_nm's in batches and wait for them to complete
}
\details{
if you need all the runs to complete ensure you use a \code{\link{wait_finish}} statement afterwards as R console will only be blocked for until the last batch has been submitted which will be before all runs have completed
}
\seealso{
\code{\link{run_nm}}
}
