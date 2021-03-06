% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_object.R
\name{block}
\alias{block}
\title{Create omega/sigma block from init_omega() and init_sigma() output}
\usage{
block(iomega, eta_numbers = NA, diag_init = 0.01)
}
\arguments{
\item{iomega}{tibble.  Output from init_omega() and init_sigma()}

\item{eta_numbers}{numeric vector.  ETA numbers to put into a block. Must be contiguous}

\item{diag_init}{numeric. Default value for off diagonal elements}
}
\description{
Create omega/sigma block from init_omega() and init_sigma() output
}
\examples{

\dontrun{
io <- m1 \%>\% init_omega()
io <- io \%>\% block(c(2,3))
m1 <- m1 \%>\% init_omega(io)
m1 \%>\% dollar("OMEGA") ## to display $OMEGA
}

}
\seealso{
\code{\link{unblock}}, \code{\link{init_theta}}
}
