#' Load data frame of foraging data that was previously saved using save_forage_data
#'
#'
#' @param file string or vector of strings; complete path to file name or vector of file paths. If a vector, returns one data frame.
#'
#' @return resulting data frame
#'
#' @export
load_forage_data = function(file, as_dt=T){

  dat = data.frame()
  for(i in 1:length(file)){
    ext = tools::file_ext(file[i])
    if(ext == "csv"){
      if(as_dt)
        this_dat = fread(file[i])
      else
        this_dat = read.csv(file[i])
    }else if(ext == "Rdata"){
      this_dat = readRDS(file[i])
      if(as_dt)
        this_dat = setDT(this_dat)
    }else{
      stop("ERROR :: File type not recognized")
    }

    dat = rbind(dat, this_dat)
  }

  return(dat)
}
