% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_object.R
\name{ls_tempfiles}
\alias{ls_tempfiles}
\title{get all temp files}
\usage{
ls_tempfiles(
  object = ".",
  output_loc = c("run_dir", "base"),
  run_files = NA_character_,
  include_grid_files = TRUE,
  ctl_extension = "mod",
  remove_psn_exports = FALSE
)
}
\arguments{
\item{object}{nm object or path to project (default = ".")}

\item{output_loc}{character either "run_dir" (default) for psn runs or "base" for nmfe runs}

\item{run_files}{optional character with NM_run* file paths}

\item{include_grid_files}{logical (default = TRUE) should slurm files be included}

\item{ctl_extension}{character. Extension of control file (default = "mod")}

\item{remove_psn_exports}{logical (default = FALSE). should psn exports be considered temporary}
}
\description{
list all tempfiles (normally for deletion)
}
\details{
Having \code{remove_psn_exposure = TRUE} will break pirana and xpose capability
  as these software use exported files
}
