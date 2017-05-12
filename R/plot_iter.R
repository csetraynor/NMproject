#' Plot iterations vs parameters/OBJ
#'
#' @param r object of class nmexecute
#' @param trans logical. should parameter transformations be performed
#' @param skip numeric (default 0). how many iterations to skip when plotting
#' @param yvar character (default = "OBJ"). Name of variable/parameter to display
#' @export
plot_iter <- function(r,trans=TRUE,skip=0,yvar="OBJ"){

  d <- read_ext(r=r,trans=trans)

  d <- d[d$TYPE %in% c("ITER","BURN"), ]
  d$EST.NAME2 <- paste("$EST",d$EST.NO,":",d$EST.NAME,sep=" ")

  ####################################
  ## find "estimation" est.no
  ## will this work with FOCE evaluation?
  if(length(unique(d$EST.NO))>1){
    est.no <- max(unique(d$EST.NO[!grepl("Eval",d$EST.NAME)]))
  } else est.no <- max(unique(d$EST.NO))
  ####################################
  d <- d[d$EST.NO %in% est.no, ]

  par.names <- names(d)[2:(match("OBJ",names(d))-1)]
  ## remove fixed parameters
  for(i in par.names) if(length(unique(d[,i]))==1) d[,i] <- NULL

  ## TODO: would like to remove all duplicated IOV ETAs

  ## move up the NBURN to immediately before NITER
  d <- by(d,d$EST.NO,function(d){

    d <- d[d$ITERATION>=min(d$ITERATION)+skip,]  ## skip first few iterations on non-evaluation methods.

    if(!"BURN"%in%d$TYPE | length(which(d$TYPE%in%"BURN"))==1)return(d)
    max.burn <- sort(d$ITERATION[d$TYPE%in%"BURN"],decreasing=TRUE)[1]
    max.burn2 <- sort(d$ITERATION[d$TYPE%in%"BURN"],decreasing=TRUE)[2]
    burn.interval <- max.burn-max.burn2
    d$ITERATION[d$TYPE%in%"BURN"] <- d$ITERATION[d$TYPE%in%"BURN"] - max.burn - burn.interval
    d
  })
  d <- do.call(rbind,d)

  par.names <- c("OBJ",names(d)[names(d) %in% par.names])

  d <- tidyr::gather_(data = d,key = "variable",value = "value",
                      gather_cols = par.names)
  d$variable <- factor(d$variable,levels=unique(d$variable))

  p <- ggplot2::ggplot(d,ggplot2::aes_string(x="ITERATION",y="value"))
  p <- p + ggplot2::geom_line(ggplot2::aes_string(colour="TYPE"))
  p <- p + ggplot2::geom_point(ggplot2::aes_string(colour="TYPE"))
  p <- p + ggplot2::facet_wrap(~variable,scale="free")
  p <- p + ggplot2::theme(legend.position="none")
  p <- p + ggplot2::ggtitle(unique(d$EST.NAME))
  p <- p + ggplot2::theme_bw()
  p
}
