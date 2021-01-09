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

  dat[, valid_patch := ifelse(Decision[1]==1 | sum(RewardVolume_mL) <= 0, F, T), .(PatchNum)]
  dat[valid_patch==T & PatchNum==max(PatchNum), valid_patch := ifelse(Decision[.N]==1, F, T)]
  if(leverOmission){
    dat[, last_decision_1 := c(NA, Decision[-.N])]
    dat[, last_decision_2 := c(NA, last_decision_1[-.N])]
    dat[, last_decision_3 := c(NA, last_decision_2[-.N])]
    dat[valid_patch==T, valid_patch := ifelse(sum((last_decision_1==2) & (last_decision_2==2) & (last_decision_3==2)) > 0, F, T)]
    dat[, last_decision_1 := NULL]
    dat[, last_decision_2 := NULL]
    dat[, last_decision_3 := NULL]
  }

  # add patch data
  dat[, PressPatch := NaN]
  dat[, PressPatch_Inv := NaN]
  dat[, startVolume := NaN]
  dat[, PatchTime := NaN]

  dat[valid_patch==T, PressPatch := 1:.N, .(PatchNum)]
  dat[valid_patch==T, PressPatch_Inv := -rev(PressPatch-1), .(PatchNum)]
  dat[valid_patch==T, startVolume := RewardVolume_mL[RewardVolume_mL > 0][1], .(PatchNum)]
  dat[valid_patch==T, PatchTime := cumsum(TrialTime), .(PatchNum)]

  #remove omissions
  if(removeOmission) dat = dat[Omission==0]
  if(leverOmission) dat = dat[Decision!=2]
  if(removeIncomplete) dat = dat[valid_patch==T]

  # remove valid_patch column
  dat[, valid_patch := NULL]

  return(dat)
}
