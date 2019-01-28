#' Save data frame of foraging data to a file
#'
#'
#' @param dat data frame; created by med_to_dt or get_patch_data function (latter is recommended)
#' @param path string (optional); complete path to save directory, if not given, uses current working directory
#' @param name string (optional); base name of file . if not provided, default is 'subject_date' of first row
#' @param as_csv logical; if true, save as .csv file. if false, save as .Rdata file with a data frame called 'forage_data'. default=false
#'
#' @return complete path to saved file
#' @export
save_forage_data = function(dat, path="", name="", as_csv=F){

  if(name==""){
    name = paste(dat$Subject[1], dat$Date[1], sep="_")
  }

  if(as_csv){
    name = paste(name, ".csv", sep="")
    if(path !=""){
      name = file.path(path, name)
    }
      write.csv(dat, name)
  }else{
    name = paste(name, ".Rdata", sep="")
    if(path != ""){
      name = file.path(path, name)
    }
    forage_data = dat
    saveRDS(forage_data, name)
  }

  return(name)

}
