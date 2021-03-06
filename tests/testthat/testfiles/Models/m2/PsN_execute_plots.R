#START OF AUTO-GENERATED PREAMBLE, WILL BE OVERWRITTEN WHEN THIS FILE IS USED AS A TEMPLATE
#Created 2020-09-29 at 15:02

rplots.level <- 1
xpose.runno <- 'm2'
toolname <- 'execute'
pdf.filename <- paste0('PsN_',toolname,'_plots.pdf')
pdf.title <- 'execute diagnostic plots run m2'
working.directory<-'/home/klgk669/NMproject/tests/testthat/test_nmproject/Models/m2_1/'
raw.results.file <- 'raw_results_runm2.csv'
model.directory<-'/home/klgk669/NMproject/tests/testthat/test_nmproject/Models/'
model.filename<-'runm2.mod'
subset.variable<-NULL
mod.suffix <- '.mod'
mod.prefix <- 'run'
tab.suffix <- ''
theta.labels <- c('KA','K','V2','add error','prop error','TVK23','TVK32')
theta.fixed <- c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)
omega.labels <- c('IIV_KA','IIV_K','IIV_V2','IIV_K23','IIV_K32')
omega.fixed <- c(FALSE,FALSE,FALSE,FALSE,FALSE)
sigma.labels <- c('SIGMA(1,1)')
sigma.fixed <- c(TRUE)
n.eta <- 5
n.eps <- 1

pdf.filename <- paste0(mod.prefix,xpose.runno,'_plots.pdf')

setwd(working.directory)

############################################################################
#END OF AUTO-GENERATED PREAMBLE
#WHEN THIS FILE IS USED AS A TEMPLATE THIS LINE MUST LOOK EXACTLY LIKE THIS



library(xpose4)

xpdb<-xpose.data(xpose.runno,directory=model.directory,tab.suffix=tab.suffix,mod.prefix=mod.prefix,mod.suffix=mod.suffix)

pdf(file=pdf.filename,width=10,height=7,title=pdf.title)

#uncomment below to change the idv from TIME to something else such as TAD.
#Other xpose preferences could also be changed
#xpdb@Prefs@Xvardef$idv="TAD"
runsum(xpdb,dir=model.directory,
         modfile=paste(model.directory,model.filename,sep=""),
         listfile=paste(model.directory,sub(mod.suffix,".lst",model.filename),sep=""))
if (is.null(subset.variable)){
    print(basic.gof(xpdb))
    print(ranpar.hist(xpdb))
    print(ranpar.qq(xpdb))
    print(dv.preds.vs.idv(xpdb))
    print(dv.vs.idv(xpdb))
    print(ipred.vs.idv(xpdb))
    print(pred.vs.idv(xpdb))
    
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(basic.gof(xpdb,by=subset.variable,max.plots.per.page=1))
    print(ranpar.hist(xpdb,by=subset.variable,scales="free",max.plots.per.page=1))
    print(ranpar.qq(xpdb,by=subset.variable,max.plots.per.page=1))
    print(dv.preds.vs.idv(xpdb,by=subset.variable))
    print(dv.vs.idv(xpdb,by=subset.variable))
    print(ipred.vs.idv(xpdb,by=subset.variable))
    print(pred.vs.idv(xpdb,by=subset.variable))
}
  
if (rplots.level > 1){
  #individual plots of ten random IDs
  #find idcolumn
  idvar <- xvardef("id",xpdb)
  ten.random.ids<-sort(sample(unique(xpdb@Data[,idvar]),10,replace=FALSE))
  subset.string <- paste0(idvar,'==',paste(ten.random.ids,collapse=paste0(' | ',idvar,'==')))
  
  
  if (is.null(subset.variable)){
    print(ind.plots(xpdb,subset=subset.string))
  }else{
    for (flag in unique(xpdb@Data[,subset.variable])){
      print(ind.plots(xpdb,subset=paste0(subset.variable,'==',flag,' & (',subset.string,')')))
    }
  }
  
}

dev.off()


