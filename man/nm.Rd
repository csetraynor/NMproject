% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_object.R
\name{nm}
\alias{nm}
\title{Create core NM object}
\usage{
nm(
  run_id = NA_character_,
  run_in = nm_default_dir("models"),
  parent_run_id = NA_character_,
  parent_run_in = NA_character_,
  parent_ctl_name = NA_character_,
  parent_results_dir = NA_character_,
  ctl_name = "run{run_id}.mod",
  type = "execute",
  run_dir = "{run_id}",
  results_dir = nm_default_dir("results"),
  lst_path = "{run_dir}/NM_run1/psn.lst"
)
}
\arguments{
\item{run_id}{character vector. Run identifier}

\item{run_in}{character vector. ctl file and run location}

\item{parent_run_id}{character vector (optional). Run identifier of previous run}

\item{parent_run_in}{character vector (optional). Run location of previous run}

\item{parent_ctl_name}{character vector (optional). Ctl name of previous run}

\item{parent_results_dir}{character vector (optional). results_dir of previous run}

\item{ctl_name}{character. Name of control file}

\item{type}{character (default = "execute").  Type of run to run}

\item{run_dir}{character (default = "{run_id}").  Subdirectory where PsN wll run NONMEM}

\item{results_dir}{character (default = "Results").
Directory to store results of this run}

\item{lst_path}{character (default = "{run_dir}/NM_run1/psn.lst") expected location of lst file}
}
\value{
An object of class nm_list.  Object is concatenatable.
   Length of object corresponds to length of run_id
}
\description{
Experimental new nm object interface.  Not compatible with previous system.
  The basic object this package centres around.  Most package functions act on this object.
}
\examples{
\dontrun{

m0 <- nm(run_id = "m0")
m0  ## a human readable representation
  
## nm objects can be put into tibbles to group runs together
d <- tibble(run_id = c("m1","m2"))
d$m <- nm(d$run_id)
d  

}

}
