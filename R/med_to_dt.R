#' Convert MedPC File to an R data table
#'
#' @param file string; complete path to MedPC data file
#' @param travel numeric; travel time for experiment
#' @param group string; experimental group of animal
#' @param treatment string; experimental treatment (i.e. drug)
#' @param varITI logical; if true, ITI = ITI-decision time-handling time-reward time. If false, ITI = ITI
#' @param ITI numeric; ITI for session
#' @param opto logical, was optogenetics used?
#'
#' @return data table with the following variables: \cr
#'  Subject \cr
#'  Group \cr
#'  Date = ddmmyy \cr
#'  Travel = travel time used for session \cr
#'  Treatment \cr
#'  Trial = trial number \cr
#'  Decision = 0 if lever press, 1 if nosepoke \cr
#'  DecisionRT = reaction time to make decision \cr
#'  DecisionTime = time stamp of decision during session \cr
#'  HandlingTime = time between lever press and reward port entry; 0 if nosepoke \cr
#'  RewardTime = time stamp on reward port entry \cr
#'  RewardVolume_s = reward volume in s of pump time \cr
#'  RewardVolume_mL = reward volume in mL \cr
#'  Omission = if removeOmission = F, 0 if no reward omission, 1 if omission \cr
#'  ITI = intertrial interval; 7 if lever press, 0 if nosepoke \cr
#'  TravelTime = travel time on trial; 0 if lever press, 'Travel' if nosepoke \cr
#'  TrialTime = total time for trial = DecisionRT+HandlingTime+ITI+TravelTime \cr
#'  CumulativeTime = total time foraging/day \cr
#'  CumulativeReward_mL = cumulative reward intake/day \cr
#'  InstantRate = RewardVolume_mL/TrialTime \cr
#'  CumulativeRate = cumulativeTime/CumulativeReward_mL \cr
#'
#' @export
med_to_dt<-function(file, travel=10, group="", treatment="", varITI = F, ITI = 7, opto = F){

  #check for missing parameters
  if(missing(file))
    stop("ERROR:: file not specified")

  #Source MedPC_Import file
  medData = rmedpc::import_medpc(file)

  #format date
  date = gsub("/", "", medData$'Start Date')

  #Create empty data frame with nrows==number of trials, initialize details
  if(medData$I==0){
    warning("No Trials!!!")
    return(data.table(Subject=medData$Subject, Group=group, Date=date, Travel=travel, Treatment=treatment, Trial=0))
  }

  dat = data.table(Subject = medData$Subject,
                   Group = medData$Group,
                   Date = date,
                   Travel = travel,
                   Treatment = treatment,
                   Trial = 1:medData$I,
                   Decision = medData$E,
                   DecisionRT = medData$A,
                   DecisionTime = medData$C,
                   HandlingTime = medData$B,
                   RewardTime = medData$D,
                   RewardVolume_s = medData$F,
                   RewardVolume_mL = ifelse(round(medData$F*.060233,3) > 0, round(medData$F*.060233,3), 0))

  if(varITI){
    dat[, ITI := medData$H]
  }else{
    dat[, ITI := ifelse(dat$Decision==0, ITI, 0)]
  }
  if(is.numeric(travel)) dat[, TravelTime := ifelse(Decision==1, travel, 0)] else dat[, TravelTime := ifelse(Deision==1, medData$K, 0)]

  dat[, TrialTime := DecisionRT+HandlingTime+ITI+TravelTime]
  dat[, CumulativeTime := cumsum(TrialTime)]
  dat[, CumulativeReward_mL := cumsum(RewardVolume_mL)]
  dat[, InstantRate := RewardVolume_mL / TrialTime]
  dat[, CumulativeRate := CumulativeReward_mL / CumulativeTime]

  #add opto data
  if(opto){
    dat[, LaserDecision := c(0, medData$G[-length(medData$G)])]
    dat[, PulsePerTrial := medData$J]
    dat[, optoFR := PulsePerTrial / (4 + DecisionRT)]
  }

  #detect omissions
  dat[, Omission := ifelse(Decision==0 & RewardVolume_s<=0, 1, 0)]

  return(dat)
}

