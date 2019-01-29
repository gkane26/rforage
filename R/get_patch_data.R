#' Add patch characteristics to initial data frame created by med_to_dt function
#'
#' @param dat data table; created by med_to_dt function
#' @param leverOmission logical; were there lever timeouts, default=false
#' @param removeOmission logical; remove omissions from data table; default=true
#' @param removeIncomplete logical; remove incomplete patches from data table; default=true
#'
#' @return Create patch data frame w/ variables: \cr
#'  PatchNum = patch number visited during session \cr
#'  PressPatch = presses since last reset \cr
#'  PressPatch_Inv = number of presses until reset \cr
#'  StartVolume = patch starting volume \cr
#'  PatchTime = patch time \cr
#'  PatchReward = patch reward \cr
#'  PatchRate = patch rate \cr
#'  MVT_AvRate = average reward rate according to MVT \cr
#'
#' @export
get_patch_data <- function(dat, leverOmission=F, removeOmission=T, removeIncomplete=T){

  #add patch num variable to frame
  dat[, PatchNum := cumsum(Decision)]
  dat[, PatchNum := c(0, PatchNum[-length(PatchNum)])]
  dat[, PatchNum := PatchNum + 1]

  ##First, check if valid patch
  # not valid if:
  #   left patch before entering it
  #   session ends before leaving patch
  #   patch out: 3 omissions in a row
  ##Second, find variables:
  #   presses/patch
  #   starting volume
  #   time in patch
  ##----------------
  patches = function(d){
    fullPatch = T
    if(sum(d$Decision == 0 & d$Omission == 0) == 0) fullPatch = F
    if(sum(d$Decision) < 1) fullPatch = F

    if(leverOmission){
      if(nrow(d) >= 3){
        lastTrials = (nrow(d) - 2):nrow(d)
        if(d[lastTrials[1], Decision] == 2 & d[lastTrials[2], Decision] == 2 & d[lastTrials[3], DecisionRT] == 7) fullPatch = F
      }
    }

    d$fullPatch = fullPatch

    if(fullPatch){
      pressTrials = numeric(d[,.N])
      pressTrials[(d$Decision == 0 | d$Decision == 1) & d$Omission == 0] = 1
      pressTrials = cumsum(pressTrials)
      d[, PressPatch := pressTrials]

      pressRev = numeric(d[,.N])
      pressRemain = max(pressTrials) - 1
      for(i in 1:d[,.N]){
        if(d[i, Decision] == 0 & d[i, Omission] == 0){
          pressRev[i] = -pressRemain
          pressRemain = pressRemain - 1
        }else{
          pressRev[i] = -pressRemain
        }
      }
      d[, PressPatch_Inv := pressRev]

      #starting volume
      d[, startVolume := d[Decision==0 & Omission==0, RewardVolume_mL][1]]

      #time in patch
      d[, PatchTime := cumsum(TrialTime) + as.numeric(as.character(d[1, Travel]))]
      d[Decision==1, PatchTime := d[PressPatch_Inv == -1, PatchTime] + d[Decision==1, DecisionRT]]

    }else{
      d[, PressPatch := NaN]
      d[, PressPatch_Inv := NaN]
      d[, startVolume := NaN]
      d[, PatchTime := NaN]
    }

    return(d)
  }

  dat = dat[, patches(.SD), "PatchNum"]

  #remove omissions
  if(removeOmission) dat = dat[Omission==0]
  if(leverOmission) dat = dat[Decision!=2]
  if(removeIncomplete) dat = dat[fullPatch==T]

  # remove fullPatch column
  dat[, fullPatch := NULL]

  return(dat)
}

