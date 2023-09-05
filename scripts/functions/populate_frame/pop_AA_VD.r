#' Stage Age Adjustment Factor and Volume of Distribution
#' populate V_d column with age adjustment factor * V_d
#' source loads tabs Age-Adjust 
#'
#' @param data Data frame created in [create_frame()] and modified by other functions
#' @param source a list of data frames loaded from the source file
#' @param V_d Monte Carlo varied volume of distribution in 1/kg
#'
#' @return data with new column Vd which is age adjusted
#' 
pop_AA_VD <- function(data = data.frame(), source, Vd){
  require(dplyr)
  
  # Load age-adjust source tab
  # lookup AF for each age; then populate Vd column (ageAdjust)
  AA <- source[["Age-Adjust"]]
  data <- data %>% rowwise %>% mutate("Vd" = age_adjust(AA,Days) * as.numeric(Vd)) # update V_d
  return(data)
    
}