#' @include utilsExtra.R

NULL

#' Run NONMEM jobs
#' 
#' Run nm objects.  Uses \code{system_nm()} to submit the \code{cmd()} value of object
#' 
#' @param m nm objects
#' @param ignore.stdout logical (default=TRUE). Parameter passed to system()
#' @param ignore.stderr logical (default=TRUE). Parameter passed to system()
#' @param quiet logical (default=FALSE). should system_nm output be piped to screen
#' @param intern logical. intern arg to be passed to system
#' @param force logical (default = FALSE).  Force run even results unchanged
#' @param cache_ignore_cmd logical (default = FALSE). Should check \code{cmd} field with cache?
#' @param cache_ignore_ctl logical (default = FALSE). Should check control file contents with cache?
#' @param cache_ignore_data logical (default = FALSE). Should check dataset with cache? 
#'
#' @return m with \code{job_info} fields populated.
#'
#' @export
run_nm <- function(m,
                   ignore.stdout = TRUE, ignore.stderr = TRUE,
                   quiet = getOption("quiet_run"),intern=getOption("intern"),
                   force = FALSE, 
                   cache_ignore_cmd = FALSE, cache_ignore_ctl = FALSE, cache_ignore_data = FALSE){
  UseMethod("run_nm")
}

#' @export
run_nm.nm_generic <- function(m,
                              ignore.stdout = TRUE, ignore.stderr = TRUE,
                              quiet = getOption("quiet_run"),intern=getOption("intern"),
                              force = FALSE, 
                              cache_ignore_cmd = FALSE, cache_ignore_ctl = FALSE, cache_ignore_data = FALSE){
  
  if(is.na(m)) return(m)
  
  ## write control stream
  ctl <- ctl_contents(m)
  if(length(ctl) == 1){
    if(is.na(ctl)){
      warning("no ctl_contents defined.
              Use ctl_contents() e.g. m <- m %>% ctl_contents(\"/path/to/ctl/file\")")
      return(m)
    }
  }
  
  m %>% write_ctl()
  
  ## caching
  if(!force){
    ## pull existing checksum info
    #run_cache_disk <- lapply(run_cache_paths(m), readRDS)
    if(length(run_cache_paths(m)) > 0){
      run_cache_disk <- readRDS(run_cache_paths(m))
      ## get current checksum
      current_checksums <- run_checksums(m)
      ## determine matches
      
      if(cache_ignore_cmd){  ## remove cmd check
        keep <- !names(current_checksums) %in% "cmd"
        run_cache_disk$checksums <- run_cache_disk$checksums[keep]
        current_checksums <- current_checksums[keep]
      }
      
      if(cache_ignore_ctl){  ## remove cmd check
        keep <- !names(current_checksums) %in% "ctl"
        run_cache_disk$checksums <- run_cache_disk$checksums[keep]
        current_checksums <- current_checksums[keep]
      }        
      
      if(cache_ignore_data){  ## remove cmd check
        keep <- !names(current_checksums) %in% "data"
        run_cache_disk$checksums <- run_cache_disk$checksums[keep]
        current_checksums <- current_checksums[keep]
      }
      
      ## ignore names
      names(current_checksums) <- NULL
      names(run_cache_disk$checksums) <- NULL
      
      matched <- identical(run_cache_disk$checksums, current_checksums)
      if(matched){
        message("rebuilding run from cache... use run_nm(force = TRUE) to override")
        ## update object and return
        m <- m %>% executed(TRUE)
        m <- m %>% job_info(run_cache_disk$job_info)
        m <- m %>% save_run_cache()
        return(invisible(m))    ## if up to date, skip
      }
    }
  }
  
  ## NONMEM will run from this point on
  ## check overwrite_behaviour() behaviour 
  behaviour <- overwrite_behaviour()
  #if("stop" %in% behaviour) stop("No new NONMEM runs allowed. Stopping... \n change behaviour with overwrite_behaviour()", call. = FALSE)
  if("skip" %in% behaviour) {
    message("skipping step as it would require overwriting \n change behaviour with overwrite_behaviour()")
    return(invisible(m))
  }
  
  wipe_run(m)  ## this will check for "ask" or "overwrite"
  kill_job(m)
  
  message(paste0("Running: ",type(m),":",ctl_path(m)))
  stdout0 <- system_nm(cmd = cmd(m),
                       dir = run_in(m), 
                       wait = FALSE,
                       ignore.stdout = FALSE,
                       ignore.stderr = FALSE,
                       intern=intern)
  
  if(intern) {
    cat(stdout0,sep = "\n")
    job_info <- getOption("get_job_info")(stdout0)
    if(is.null(job_info)) job_info <- NA
  } else job_info <- NA
  
  m <- m %>% executed(TRUE)
  m <- m %>% job_info(job_info)
  
  ## The object is now ready to be saved in cache
  m <- m %>% save_run_cache()

  invisible(m)
}

#' @export
run_nm.nm_list <- Vectorize_nm_list(run_nm.nm_generic, SIMPLIFY = FALSE, invisible = TRUE)

#' run_nm in batches
#' 
#' a variant of \code{run_nm()} that will submit run_nm's in batches and wait for them to complete
#' 
#' @param m nm object
#' @param threads numeric.  Number of threads to un
#' @param ... additional arguments passed to run_nm()
#' 
#' @details if you need all the runs to complete ensure you use a \code{\link{wait_finish}} statement afterwards as R console will only be blocked for until the last batch has been submitted which will be before all runs have completed 
#' 
#' @seealso \code{\link{run_nm}}
#' @export

run_nm_batch <- function(m, threads = 10, ...){
  runs_remaining <- seq_along(m)
  while(length(runs_remaining) > 0){
    n_to_take <- min(threads, length(runs_remaining))
    runs_to_run <- runs_remaining[seq_len(n_to_take)]
    m_sub <- m[runs_to_run]
    run_nm(m_sub, ...)
    runs_remaining <- setdiff(runs_remaining, runs_to_run)
    if(length(runs_remaining) > 0) wait_finish(m_sub)
  }
  m
}

#' Run NMTRAN step only
#'
#' Runs initial part of NONMEM where control file and dataset checks are performed.
#' Stops before running NONMEM.  Useful especially on grid infrastructures where 
#' it may take a while for NONMEM to start return ctl/dataset errors
#'
#' @param x nm object
#' @details
#' Requires \code{options("nmtran_exe_path")} to be set.
#' @export
nm_tran <- function(x) UseMethod("nm_tran")

#' @export
nm_tran.default <- function(x){
  
  if(is.null(nm_tran_command())) stop("nm_tran not set up, see ?nm_tran_command")
  
  tempdir0 <- basename(tempdir()) ## make temporary directory in current directory
  dir.create(tempdir0) ; on.exit(unlink(tempdir0,recursive=TRUE,force = TRUE))
  file.copy(x,tempdir0) ## copy_control file
  data_path <- file.path(dirname(x), data_name(x))
  file.copy(data_path,tempdir0) ## copy dataset
  dataset.name <- basename(data_path)
  suppressMessages({
    ctl_text <- update_dollar_data(file.path(tempdir0,basename(x)),dataset.name)
    write(ctl_text, file.path(tempdir0,basename(x)))
  })
  message("running NMTRAN on ", x)
  
  nm_tran_command <- nm_tran_command()
  cmd <- stringr::str_glue(nm_tran_command, .envir = list(ctl_name= basename(x)), .na = NULL)
  ## if non-glue - append the control file name
  if(cmd == nm_tran_command) cmd <- paste(cmd, "<", basename(x))
  
  system_nm(cmd, dir=tempdir0, wait=TRUE)
}

#' @export
nm_tran.nm_generic <- function(x){
  xtmp <- x %>% run_in(file.path(run_in(x), "temp"))
  xtmp %>% write_ctl(force = TRUE)
  nm_tran.default(ctl_path(xtmp))
  invisible(x)
}
#' @export
nm_tran.nm_list <- Vectorize_nm_list(nm_tran.nm_generic, SIMPLIFY = FALSE, invisible = TRUE)


#' wipe previous run files
#'
#' @param r object class nm
#' @export
wipe_run <- function(r){
  UseMethod("wipe_run")
}

#' @export
wipe_run.nm_generic <- function(r){
  ## assumes ctrl file is run[run_id].mod and -dir=[run_id] was used
  
  ## get and remove all ctl output files
  
  ## files are in run_in(r)
  ## assume same stub as input.
  
  psn_exported_files <- psn_exported_files(r)
  
  # ## do not include scm or mod
  # output_files <- paste0(tools::file_path_sans_ext(ctl_path(r)),
  #       c(".phi", ".ext", ".cov", ".coi", ".cor", ".lst"))
  
  ## and output - in case it's different  
  lst_path <- file.path(run_in(r), lst_path(r))
  
  # ## need to get table files too
  # ctl_table_files <- file.path(run_in(r), ctl_table_files(r))
  
  ## run_dir
  run_dir_to_delete <- file.path(run_in(r), run_dir(r))
  if(!file.exists(run_dir_to_delete)) run_dir_to_delete <- c() else {
    ## can now assume directory exists
    ## make sure it's not the same directory the ctl file is in
    if(run_dir_to_delete %in% c(".", ".\\")) run_dir_to_delete <- c() else {
      if(normalizePath(run_dir_to_delete) == normalizePath(run_in(r))) run_dir_to_delete <- c()
    }
  }
  
  #ctl_out_files <- c(lst_path, output_files, ctl_table_files, run_dir_to_delete)
  ctl_out_files <- c(lst_path, psn_exported_files, run_dir_to_delete)
  
  ## before deleting files, check
  existing_ctl_out_files <- ctl_out_files[file.exists(ctl_out_files)]
  behaviour <- overwrite_behaviour()
  if("stop" %in% behaviour & length(existing_ctl_out_files) > 0)
    stop("no overwriting allowed, stopping due to following files/directories:\n ",
         paste(paste(existing_ctl_out_files, collapse = "\n ")))
  prompt_overwrite(rev(existing_ctl_out_files))
  
  unlink(ctl_out_files, recursive = TRUE, force = TRUE)
  
  invisible()
}

#' @export
wipe_run.nm_list <- Vectorize_nm_list(wipe_run.nm_generic, SIMPLIFY = FALSE, invisible = TRUE)

prompt_overwrite <- function(paths, new_path_contents = c()){
  
  if(length(paths) == 0) return(NA_character_)
  
  behaviour <- overwrite_behaviour()  
  if(!"ask" %in% behaviour) return(NA_character_)
  
  question <- "The following directories & files will be overwritten"
  msg <- paste(paste(paths, collapse = "\n "))
  
  if(length(new_path_contents) > 0 & requireNamespace("diffobj")){
    if(length(paths) > 1) stop("can only do diff with one path")
    if(!is.character(new_path_contents)) stop("expecting character vector for new_path_contents")
    ## can now assume one path
    old_contents <- readLines(paths)
    new_contents <- new_path_contents
    attributes(new_contents) <- NULL
    if(!identical(new_contents, old_contents)){
      diff_val <- diffobj::diffChr(old_contents, new_contents, format = "raw") 
      if(length(as.character(diff_val)) <= 30) ## diff limit
        msg <- paste(msg, "\n", paste(diff_val, collapse = "\n"))
    } else {
      ## if same, no need to prompt
      return(NA_character_)
    }
  }
  
  if(rstudioapi::isAvailable()){
    proceed <- rstudioapi::showQuestion(question, msg, 
                                        ok = "overwrite",
                                        cancel = "abort")
  } else {
    message(question)
    message(msg)
    message("overwrite and proceed?")
    ans <- readline("Type \"y\" or \"n\": ")
    proceed <- tolower(ans) == "y"
    if(length(proceed > 1)) stop("only one answer allowed", call. = FALSE)
  }
  if(!proceed) stop("aborting", call. = FALSE)
  
}


#' Clean up temporary files
#' 
#' @param m nm object
#' @param output_loc character either "run_dir" or "base
#' @param include_grid_files logical (default = TRUE) should slurm files be included
#' 
#' @export
clean_run <- function(m, output_loc = c("run_dir", "base"), include_grid_files = TRUE){
  UseMethod("clean_run")
}
#' @export
clean_run.nm_list <- function(m, output_loc = c("run_dir", "base"), include_grid_files = TRUE){
  
  ls_tempfiles(m, output_loc = output_loc) %>%
    unlink(force = TRUE)
  
}

#' Write control file to disk
#' 
#' Normally used by other functions
#' 
#' @param m nm object
#' @param force logical (default = FALSE), force write, don't ask (ignore behaviour)
#' 
#' @export
write_ctl <- function(m, force = FALSE){
  UseMethod("write_ctl")
}

#' @export
write_ctl.nm_generic <- function(m, force = FALSE){
  
  ctl_name <- ctl_path(m)
  ctl_ob <- ctl_contents(m) %>% ctl_character()
  dir_name <- run_in(m)
  
  if(!file.exists(dir_name)) 
    dir.create(dir_name, showWarnings = FALSE, recursive = TRUE)
  
  if(file.exists(ctl_name) & !force){
    behaviour <- overwrite_behaviour()
    old_contents <- readLines(ctl_name)
    new_contents <- ctl_ob
    attributes(new_contents) <- NULL
    overwrite_required <- !identical(new_contents, old_contents)
    if(overwrite_required){
      if("stop" %in% behaviour)
        stop("stopping because overwrite required: change behaviour in overwrite_behaviour()")
      if("ask" %in% behaviour)
        prompt_overwrite(ctl_name, new_path_contents = ctl_ob)
      if("skip" %in% behaviour)
        return(invisible(m))
    }
  }
  
  writeLines(ctl_ob, ctl_name)
  invisible(m)
}
#' @export
write_ctl.nm_list <- Vectorize_nm_list(write_ctl.nm_generic, SIMPLIFY = FALSE, invisible = TRUE)




data_name <- function(x) UseMethod("data_name")

data_name.default <- function(x){
  unlist(lapply(x,function(x){
    if(!file.exists(x)) x <- from_models(x)
    if(!file.exists(x)) stop("can't find control stream")
    x <- normalizePath(x)
    ctl <- readLines(x,warn = FALSE)
    data.row <- grep("^ *\\$DATA",ctl)
    if(length(data.row)<1) stop("can't identify data row")
    if(length(data.row)>1) {
      warning("multiple data rows found. Using first")
      data.row <- data.row[1]
    }
    ctl <- paste(ctl[data.row:length(ctl)],collapse = " ")
    data_name <- gsub("^ *\\$DATA\\s*([^ ]+).*$","\\1",ctl)
    data_name
  }))
}

update_dollar_data <- function(ctl_name,new_data_name){
  if(is_single_na(ctl_name)) return(NA)
  ctl <- ctl_character(ctl_name)
  ctl <- gsub("^(\\s*\\$DATA\\s*)[^ ]+(.*)$",paste0("\\1",new_data_name,"\\2"),ctl)
  ctl
}