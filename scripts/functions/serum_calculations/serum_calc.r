#' Serum Calculation
#'
#' @param data Entire dataframe to populate
#' @param perc_tap MC varied percent drinking water intake from tap water
#' @param perc_tap_dates dates of changes in perc_tap
#' @param timestep the number of days between calculations, from parameter list
#' @param numChild number of children given birth to, from parameter list
#' @param child_bday birthdays of children, from parameter list
#' @param gender  gender, either "Male" or "Female", from parameter list
#' @param child_bf_mo number of months child was breastfed, from parameter list
#' @param sd start date, the user's birthday, from parameter list
#' @param creation_date date to use when calculating the current age
#' @param mom_pct_tap percent drinking water intake from tap water for the mother at birth
#' @param MatXfer MC varied Maternal Transfer Rate from serum to breast milk 
#' @param PlacXfer MC varied Serum Placental Transfer Rate from mother's serum to infant's serum
#' @param MilkClear MC varied Milk Clearance Rate from breast milk
#' @param MatRemove MC varied Maternal Removal Rate from mother's serum
#' @param HL MC varied half life (in years)
#' @param VD MC varied volume of distribution
#' @param BGF MC varied adult female background serum (for mother's steady state serum concentration)
#' @param fed_most Either "breast milk", "tap water", or "other formula" to represent the largest water source as an infant
#'
#' @return dataframe populated with BMC, mother_serum, Daily_Dose_DW, Daily_Dose_BM, Serum_a, and Serum_b
#'
#' @examples
#' 
#' result <- serum_calc(data = staged_frame, timestep = parameter_list$timestep,
#'    numChild = parameter_list$numChild, 
#'    child_bday = parameter_list$child_bday, child_bf_mo = parameter_list$child_bf_mo, 
#'    sd = parameter_list$sd, creation_date = parameter_list$creation_date,
#'    gender= parameter_list$gender, mom_pct_tap = parameter_list$mom_pct_tap,
#'    perc_tap = perc_tap,  perc_tap_dates = parameter_list$perc_tap_dates,
#'    MatXfer = MatXfer, PlacXfer = PlacXfer, 
#'    MilkClear = MilkClearance, MatRemove = MatRemove, 
#'    HL = HL, VD = V_d,  BGF = BkgdF, # for mother's serum calc
#'    fed_most = parameter_list$fed_most) 
#' 
serum_calc <- function(data, perc_tap, perc_tap_dates, timestep, 
                       numChild, child_bday,gender, child_bf_mo,
                       sd, creation_date, mom_pct_tap,
                       MatXfer, PlacXfer, MilkClear, MatRemove, HL, VD, BGF,
                       fed_most){
  
  if(is.list(perc_tap)){perc_tap <- unlist(perc_tap)}
  
  # calculate clearance rates
  HL <- HL *365 # convert to days
  
  # calculate decay per timestep
  k <- log(2)/HL
  DecayPerStep <- exp(-(k)*timestep)
  
  # If a mother with children, calculate a modified decay step accounting for additional breast milk clearance.
  if(gender == "Female" & numChild > 0){
    numinf <- sum(!is.na(child_bf_mo))
    
    if(is.na(numinf)){numinf <- 0}
    
    if(numinf > 1){ # checking for any child birthdays in same year and adjusting clearance rate
      numinf <- numinf / length(unique(year(child_bday[which(!is.na(child_bf_mo))]))) 
    }
    if(numinf > 1){ numinf <- (1 + ((numinf - 1)*0.5 )) } # giving lesser weight to additional kids in same year
    
  }else{numinf<- 0}
  
  # calculate the mother's Clearance Rate from Breast Feeding
  tempHL <- (180 * -log(2) ) / ( log( (1-MatRemove) ))
  k2 <- (log(2)/tempHL)*numinf
  CRBFPerStep = exp(-(k+k2)*timestep)
  # calculate the breast milk clearnance rate
  tempHL <- (180 * -log(2) ) / ( log( (1-MilkClear) ))
  BMCk <- (log(2)/tempHL)
  BMCRPerStep = exp(-BMCk*timestep)
  
  # add column for which days a mother is breastfeeding
  data <- bf_days(data = data,  
                  gender = gender, 
                  child_bday = child_bday, 
                  child_bf_mo = child_bf_mo)
  
  # add column of daily dose from drinking water to frame
  data <- data %>% mutate(Daily_Dose_DW = (as.numeric(DWC)/1000)*(as.numeric(DWI)/1000)/BW)
  
  # apply percent tap 
  data <- data %>% rowwise %>% # use maximum index such that the date is smaller
    mutate(Daily_Dose_DW = Daily_Dose_DW * 
             as.numeric(perc_tap)[max(which(perc_tap_dates <= as.Date(Date, 
                                                                     origin = "1970-1-1")))])
  
  curage <- as.Date(creation_date, origin = "1970-1-1") - as.Date(sd, 
                                                                  origin = "1970-1-1") 
  curage <- as.numeric(curage)/ 365
  
  if(is.na(mom_pct_tap)){mom_pct_tap <- perc_tap[[1]]} # if NA, set mom's perc tap to first pct tap
  
  # add column of BM daily dose 
  # add col for mother's serum for calculating starting child serum (<6)
  data <- dailyDose_BM(data = data, curage = curage, CRBFPerStep = CRBFPerStep,
                      BMCRPerStep = BMCRPerStep, MatXfer  = MatXfer, 
                      mom_pctap = mom_pct_tap, HL = HL,
                       BGF = BGF, VD = VD)
  
  # calculate individual blood serums
  data <- data %>%  # calculate the daily dose from both water and breast milk
    mutate("DD" = ((Daily_Dose_DW + Daily_Dose_BM)/ Vd)) 

  BF <- ifelse(fed_most == "breast milk" & curage < 6, TRUE, FALSE)
  if(nrow(data) <= 650){
    serums <- recursive_serum(data = data, timestep = timestep,  iter = nrow(data), 
                              decay = DecayPerStep, decay_bf = CRBFPerStep,
                              curage = curage, PlacXfer = PlacXfer, bf = BF)
    
  }else{
    serums <- recursive_large(data = data, timestep = timestep,  iter = nrow(data), 
                              decay = DecayPerStep, decay_bf = CRBFPerStep,
                              curage = curage, PlacXfer = PlacXfer,bf = BF)
    
  }
  
  data$Serum_a <- serums$Serum_a
  data$Serum_b <- serums$Serum_b
  
  return(data)
}
 