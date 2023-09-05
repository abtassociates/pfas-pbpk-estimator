#' Populate Drinking Water Intake and Breast Milk Intake
#' populate DWI column & adjust with DWIaf
#' source loads tabs DWI & Breastfeeding 
#' the Breastfeeding tab also contains the DWI values for infants (<1)
#'
#' @param data Data frame created in [create_frame()] and modified by other functions
#' @param source List of data frames loaded from the source file
#' @param fed_most primary source of water as an infant. Either "breast milk", "tap water", or "other formula"; passed from parameter_list
#' @param fed_mo Number of months the user was breastfed; passed from parameter_list
#' @param AF Monte Carlo varied adjustment factor for drinking water intake
#' @param dwi_unit Water intake units; default is set to mL/day. Set to mL/kg*day to use the body weight adjusted calculation.
#'
#' @return data with new columns DWI and BMI 
pop_DWI_BMI <- function(data, source,  fed_most, fed_mo, AF = 1, dwi_units = "mL/day"){
  
  if(is.na(fed_mo)){fed_mo <- case_when(fed_most == "breast milk" ~ 6,
                                        fed_most == "other formula" ~ 12,
                                        TRUE ~ NA_real_)}
  
  if(fed_most == "other formula" & fed_mo > 12){ fed_mo <- 12}
  if(fed_most == "breast milk" & fed_mo > 6){ fed_mo <- 6}
  
  # breastmilk
  breast_milk <- source[["BreastFeeding"]]  %>% as.data.frame()
  
  # dwi
  water_intake <- source[["DWI"]] %>% as.data.frame() %>% filter( age <= 100) # 101 added for extrapolating
  # for DWI by months for infants load from breast_milk 
  water_intake_infant <- breast_milk[which(breast_milk$Metric=="DWI"),] 
  water_intake_infant <- c(water_intake_infant[,3:ncol(water_intake_infant)]) %>% unlist
  
  # subset breastmilk
  breast_milk <- breast_milk[which(breast_milk$Metric == "BMI"),]
  breast_milk <- t(breast_milk[,3:ncol(breast_milk)]) 
  
  # populate DWI
  if(dwi_units %in% c("mL/kg*day", "mL/kg*d", "mL/kg d")){
    # smooth body weight adjusted over the first 12 months, then annually
    data <- data %>% 
      mutate("DWI" = ifelse(Months >= 12,  water_intake$DWI_mL_kg_d[Years+1]  *BW*AF,
                            seq(water_intake$DWI_mL_kg_d[1], water_intake$DWI_mL_kg_d[2], length.out = 12)[Months +1] *BW*AF ))
  }else{
    data <- data %>% mutate("DWI" = ifelse(Months >= 12,  water_intake$DWI_mL_d[Years+1] *AF,
                                           water_intake_infant[Months+1])* AF )
  }
  
  # Breast milk
  if(fed_most == "breast milk"){# if i was breastfed, populate BMI for however many months I was breastfed
    data <- data %>% mutate("BMI" = ifelse(Months >=fed_mo, 0, breast_milk[Months + 1]))
  }else{
    data$BMI <- rep(0, nrow(data))
  }
  
  # set DWI to 0 when breastfeeding or when drinking store bought formula
  if(fed_most == "other formula" | fed_most == "breast milk"){
   data <- data %>% mutate("DWI" = ifelse(Months < fed_mo, 0, DWI))
  }
  
  return(data)
}
