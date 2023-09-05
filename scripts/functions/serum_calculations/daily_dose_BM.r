#' Daily Dose from Breast Milk
#' calculate daily dose of breast milk for infants
#'
#' @param data Entire dataframe to populate
#' @param curage current age of user (at creation_date)
#' @param MatXfer MC varied Maternal Transfer rate
#' @param CRBFPerStep Mother's Serum Clearance Rate from Breastfeeding
#' @param BMCRPerStep Breast Milk Clearance Rate 
#' @param mom_pctap Mother's percent tap water intake at birth
#' @param HL MC varied halflife converted to days
#' @param VD MC varied volume of distribution
#' @param BGF MC varied adult female background serum, used in calculating mother's steady state serum
#'
#' @return dataframe with BMC (Breast Milk Concentration), mother_serum, and Daily_Dose_BM columns populated
#'
#' @examples
#' 
#' tempHL <- (180 * -log(2) ) / ( log( (1-MatRemove) ))
#' k2 <- (log(2)/tempHL)*numinf
#' CRBFPerStep = exp(-(k+k2)*timestep)
#' # calculate the breast milk clearnance rate
#' tempHL <- (180 * -log(2) ) / ( log( (1-MilkClear) ))
#' BMCk <- (log(2)/tempHL)
#'
#' BMCRPerStep = exp(-BMCk*timestep)
#' # add column of BM daily dose 
#' # add col for mother's serum for calculating starting infant serum (<6)
#' data <- dailyDose_BM(data = data, curage = 30, CRBFPerStep = CRBFPerStep,
#'                     BMCRPerStep = BMCRPerStep, MatXfer  = MatXfer, 
#'                     mom_pctap = 1, HL = HL,
#'                     BGF = BGF, VD = VD)
#' 
dailyDose_BM <- function(data, curage, MatXfer, 
                         CRBFPerStep, BMCRPerStep, mom_pctap ,  HL, VD, BGF){
  
  data$Daily_Dose_BM <- rep(0, nrow(data)) # add empty col

  dwc <-  as.data.frame(data)[1,"DWC"]
  
  # calculate steady state mother's serum
  mother_serum <- (dwc/1000 * mom_pctap * 0.0229 * HL ) /( VD * log(2)) + (BGF/1000)
  
  bmc  <- mother_serum * MatXfer 
  
  if(curage >=6){BMC <- 0} # if over 6 years old, no contribution from breastmilk
  data <- data %>% 
    mutate("BMC" = bmc * (BMCRPerStep)^(id), # no end
           "mother_serum" = mother_serum * (CRBFPerStep)^(id)) %>% # let mom's serum change with BM clearance
    mutate("Daily_Dose_BM" = ifelse(curage >= 6, 0, BMC*BMI/BW)) %>% # BMI = 0 after bf_mo months
    mutate(BMC = ifelse(BMI>0, BMC, 0)) # drop BMC after breastfeeding
          
  return(data)
}
